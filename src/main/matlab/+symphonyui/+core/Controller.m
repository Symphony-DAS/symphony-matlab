classdef Controller < symphonyui.core.CoreObject

    properties (SetObservable, SetAccess = private)
        state
    end

    properties (SetAccess = private)
        currentProtocol
        currentPersistor
    end

    properties (Access = private)
        devices
        epochQueueDuration
    end

    properties (Constant, Access = private)
        MAX_EPOCH_QUEUE_DURATION = seconds(3)
        INTERVAL_KEYWORD = '_INTERVAL_'
    end

    methods

        function obj = Controller()
            import symphonyui.core.util.NetListener;

            cobj = Symphony.Core.Controller();
            obj@symphonyui.core.CoreObject(cobj);

            obj.state = symphonyui.core.ControllerState.STOPPED;
            obj.devices = {};
        end

        function setRig(obj, rig)
            obj.cobj.DAQController = [];
            obj.cobj.Clock = [];
            obj.removeAllDevices();

            if isempty(rig)
                return;
            end

            obj.cobj.DAQController = rig.daqController.cobj;
            obj.cobj.Clock = rig.daqController.cobj.Clock;

            devs = rig.devices;
            for i = 1:numel(devs)
                obj.addDevice(devs{i});
            end
        end

        function runProtocol(obj, protocol, persistor)
            if obj.state.isPaused()
                error('Controller is paused');
            end

            onRunEnded = onCleanup(@()obj.endRun());
            obj.beginRun(protocol, persistor);

            obj.run();
        end

        function resume(obj)
            if ~obj.state.isPaused()
                error('Controller not paused');
            end

            onRunEnded = onCleanup(@()obj.endRun());

            obj.run();
        end

        function requestPause(obj)
            if ~obj.state.isRunning()
                return;
            end
            obj.state = symphonyui.core.ControllerState.PAUSING;
            obj.tryCore(@()obj.cobj.RequestPause());
        end

        function requestStop(obj)
            if obj.state.isPaused()
                obj.state = symphonyui.core.ControllerState.STOPPED;
                obj.endRun();
                return;
            end
            if ~obj.state.isRunning()
                return;
            end
            obj.state = symphonyui.core.ControllerState.STOPPING;
            obj.tryCore(@()obj.cobj.RequestStop());
        end

        function d = get.epochQueueDuration(obj)
            cdur = obj.cobj.EpochQueueDuration;
            if cdur.IsNone()
                d = seconds(inf);
            else
                d = obj.durationFromTimeSpan(cdur.Item2);
            end
        end

    end

    methods (Access = protected)

        function beginRun(obj, protocol, persistor)
            obj.currentProtocol = protocol;
            obj.currentPersistor = persistor;

            obj.clearEpochQueue();

            protocol.prepareRun();

            if ~isempty(persistor)
                for i = 1:numel(obj.devices)
                    device = obj.devices{i};
                    pDevice = persistor.device(device.name, device.manufacturer);
                    
                    resourceNames = device.getResourceNames();
                    pResourceNames = pDevice.getResourceNames();
                    
                    for k = 1:numel(resourceNames)
                        name = resourceNames{k};
                        if any(strcmp(name, pResourceNames))
                            if ~isequal(device.getResource(name), pDevice.getResource(name))
                                error([device.name ' already contains a resource named ''' name ''' with a different value']);
                            end
                        else
                            pDevice.addResource(name, device.getResource(name));
                        end
                    end
                end
                
                map = protocol.getPropertyDescriptors().toMap();
                keys = map.keys;
                for i = 1:numel(keys)
                    map(keys{i}) = obj.propertyValueFromValue(map(keys{i}));
                end
                persistor.beginEpochBlock(class(protocol), map);
            end
        end

        function endRun(obj)
            if obj.state.isPaused()
                return;
            end

            protocol = obj.currentProtocol;
            persistor = obj.currentPersistor;
            obj.currentProtocol = [];
            obj.currentPersistor = [];

            if ~isempty(persistor) && ~isempty(persistor.currentEpochBlock)
                persistor.endEpochBlock();
            end

            protocol.completeRun();
        end

    end

    methods (Access = private)

        function addDevice(obj, device)
            obj.tryCore(@()obj.cobj.AddDevice(device.cobj));
            obj.devices{end + 1} = device;
        end

        function removeAllDevices(obj)
            obj.tryCore(@()obj.cobj.RemoveAllDevices());
            obj.devices = {};
        end

        function run(obj)
            import symphonyui.core.util.NetListener;
            import symphonyui.core.ControllerState;

            listeners = NetListener.empty(0, 1);

            listeners(end + 1) = NetListener(obj.cobj, 'Started', 'Symphony.Core.TimeStampedEventArgs', @(h,d)onStarted(obj,h,d));
            function onStarted(obj, ~, ~)
                if obj.state.isPausing()
                    obj.tryCore(@()obj.cobj.RequestPause());
                elseif obj.state.isStopping()
                    obj.tryCore(@()obj.cobj.RequestStop());
                end
            end

            listeners(end + 1) = NetListener(obj.cobj, 'CompletedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @(h,d)onCompletedEpoch(obj,h,d));
            function onCompletedEpoch(obj, ~, event)
                epoch = symphonyui.core.Epoch(event.Epoch);
                try
                    if any(strcmp(epoch.keywords, obj.INTERVAL_KEYWORD))
                        obj.currentProtocol.completeInterval(epoch);
                    else
                        obj.currentProtocol.completeEpoch(epoch);
                    end
                catch ex
                    obj.requestStop();
                    rethrow(ex);
                end
                if ~obj.currentProtocol.shouldContinueRun()
                    obj.requestStop();
                end
            end

            listeners(end + 1) = NetListener(obj.cobj, 'DiscardedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @(h,d)onDiscardedEpoch(obj,h,d));
            function onDiscardedEpoch(obj, ~, ~)
                obj.requestStop();
            end

            if isempty(obj.currentPersistor)
                obj.state = ControllerState.VIEWING;
            else
                obj.state = ControllerState.RECORDING;
            end

            try
                obj.process();
            catch x
                delete(listeners);
                obj.state = ControllerState.STOPPED;
                rethrow(x);
            end

            delete(listeners);
            if obj.state.isPausing()
                if isempty(obj.currentPersistor)
                    obj.state = ControllerState.VIEWING_PAUSED;
                else
                    obj.state = ControllerState.RECORDING_PAUSED;
                end
            else
                obj.state = ControllerState.STOPPED;
            end
        end

        function process(obj)
            if ~obj.currentProtocol.shouldContinueRun()
                return;
            end

            obj.preloadLoop();

            task = obj.startAsync(obj.currentPersistor);

            try
                obj.processLoop();
            catch x
                obj.requestStop();
                while obj.cobj.IsRunning
                    pause(0.01);
                end
                obj.tryCore(@()obj.cobj.WaitForCompletedEpochTasks());
                rethrow(x);
            end

            while obj.cobj.IsRunning
                pause(0.01);
            end
            obj.tryCore(@()obj.cobj.WaitForCompletedEpochTasks());

            if task.IsFaulted
                error(symphonyui.core.util.netReport(task.Exception.Flatten()));
            end
        end

        function preloadLoop(obj)
            while obj.shouldContinuePreloadingEpochs()
                obj.enqueueEpoch(obj.nextEpoch());
                obj.enqueueEpoch(obj.nextInterval());
                drawnow();
            end
        end

        function tf = shouldContinuePreloadingEpochs(obj)
            tf = obj.currentProtocol.shouldContinuePreloadingEpochs() ...
                && obj.epochQueueDuration < obj.MAX_EPOCH_QUEUE_DURATION ...
                && obj.state.isRunning();
        end

        function processLoop(obj)
            while obj.shouldWaitToContinuePreparingEpochs()
                pause(0.01);
            end
            while obj.shouldContinuePreparingEpochs()
                obj.enqueueEpoch(obj.nextEpoch());
                obj.enqueueEpoch(obj.nextInterval());
                drawnow();
                while obj.shouldWaitToContinuePreparingEpochs()
                    pause(0.01);
                end
            end
        end

        function tf = shouldWaitToContinuePreparingEpochs(obj)
            tf = (obj.currentProtocol.shouldWaitToContinuePreparingEpochs() ...
                || obj.epochQueueDuration >= obj.MAX_EPOCH_QUEUE_DURATION) ...
                && obj.state.isRunning();
        end

        function tf = shouldContinuePreparingEpochs(obj)
            tf = obj.currentProtocol.shouldContinuePreparingEpochs() ...
                && obj.state.isRunning();
        end

        function e = nextEpoch(obj)
            e = symphonyui.core.Epoch(class(obj.currentProtocol));

            for i = 1:numel(obj.devices)
                d = obj.devices{i};
                if ~isempty(d.outputStreams)
                    e.setBackground(d, d.background);
                end
            end

            obj.currentProtocol.prepareEpoch(e);
        end

        function i = nextInterval(obj)
            i = symphonyui.core.Epoch(class(obj.currentProtocol));
            i.shouldBePersisted = false;
            i.addKeyword(obj.INTERVAL_KEYWORD);

            for k = 1:numel(obj.devices)
                d = obj.devices{k};
                if ~isempty(d.outputStreams)
                    i.setBackground(d, d.background);
                end
            end

            obj.currentProtocol.prepareInterval(i);
        end

        function enqueueEpoch(obj, epoch)
            obj.tryCore(@()obj.cobj.EnqueueEpoch(epoch.cobj));
        end

        function clearEpochQueue(obj)
            obj.tryCore(@()obj.cobj.ClearEpochQueue());
        end

        function t = startAsync(obj, persistor)
            if isempty(persistor)
                cper = [];
            else
                cper = persistor.cobj;
            end
            t = obj.tryCoreWithReturn(@()obj.cobj.StartAsync(cper));
        end

    end

end
