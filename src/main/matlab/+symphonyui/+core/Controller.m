classdef Controller < symphonyui.core.CoreObject
    % A Controller serves to run protocols and maintain the epoch queue.
    
    properties (SetObservable, SetAccess = private)
        state   % State of this controller (stopped, paused, running, etc.)
    end

    properties (SetAccess = private)
        rig                 % Rig assigned to this controller in setRig()
        currentProtocol     % Current running or paused protocol
        currentPersistor    % Current persistor or empty if there is no current persistor
    end

    properties (Access = private)
        epochQueueDuration  % Current duration of the epoch queue
    end

    properties (Constant, Access = private)
        MAX_EPOCH_QUEUE_DURATION = seconds(3)   % Max allowable duration of the epoch queue
        INTERVAL_KEYWORD = '_INTERVAL_'         % Keyword tag to distinguish interval epochs from regular epochs
    end

    methods

        function obj = Controller()
            cobj = Symphony.Core.Controller();
            obj@symphonyui.core.CoreObject(cobj);

            obj.state = symphonyui.core.ControllerState.STOPPED;
        end

        function setRig(obj, rig)
            obj.cobj.DAQController = [];
            obj.cobj.Clock = [];
            obj.tryCore(@()obj.cobj.RemoveAllDevices());

            obj.cobj.DAQController = rig.daqController.cobj;
            obj.cobj.Clock = rig.daqController.cobj.Clock;

            devs = rig.devices;
            for i = 1:numel(devs)
                obj.tryCore(@()obj.cobj.AddDevice(devs{i}.cobj));
            end

            obj.rig = rig;
        end

        function runProtocol(obj, protocol, persistor)
            if obj.state.isPaused()
                error('Controller is paused');
            end
            if obj.state.isRunning()
                return;
            end

            try
                obj.prepareRun(protocol, persistor);
                obj.run();
            catch x
                obj.completeRun();
                rethrow(x);
            end

            obj.completeRun();
        end

        function resume(obj)
            if ~obj.state.isPaused()
                error('Controller not paused');
            end

            if isempty(obj.state.isViewingPaused())
                obj.state = symphonyui.core.ControllerState.VIEWING;
            else
                obj.state = symphonyui.core.ControllerState.RECORDING;
            end

            try
                obj.run();
            catch x
                obj.completeRun();
                rethrow(x);
            end

            obj.completeRun();
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
                obj.completeRun();
                return;
            end
            if ~obj.state.isRunning() && ~obj.state.isPausing()
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

        function prepareRun(obj, protocol, persistor)
            import symphonyui.core.ControllerState;

            obj.currentProtocol = protocol;
            obj.currentPersistor = persistor;

            if isempty(persistor)
                obj.state = ControllerState.VIEWING;
            else
                obj.state = ControllerState.RECORDING;
            end

            obj.clearEpochQueue();

            protocol.prepareRun();

            if ~isempty(persistor)
                map = protocol.getPropertyMap();
                keys = map.keys;
                for i = 1:numel(keys)
                    map(keys{i}) = obj.propertyValueFromValue(map(keys{i}));
                end
                persistor.beginEpochBlock(class(protocol), map);
            end
        end

        function completeRun(obj)
            import symphonyui.core.ControllerState;

            protocol = obj.currentProtocol;
            persistor = obj.currentPersistor;

            if obj.state.isPausing()
                if isempty(persistor)
                    obj.state = ControllerState.VIEWING_PAUSED;
                else
                    obj.state = ControllerState.RECORDING_PAUSED;
                end
                return;
            end

            if ~isempty(persistor) && ~isempty(persistor.currentEpochBlock)
                persistor.endEpochBlock();
            end

            try
                protocol.completeRun();
            catch x
                obj.state = ControllerState.STOPPED;
                obj.currentProtocol = [];
                obj.currentPersistor = [];
                rethrow(x);
            end

            obj.state = ControllerState.STOPPED;
            obj.currentProtocol = [];
            obj.currentPersistor = [];
        end

    end

    methods (Access = private)

        function run(obj)
            import symphonyui.core.util.NetListener;

            listeners = NetListener.empty(0, 1);

            listeners(end + 1) = NetListener(obj.cobj, 'Started', 'Symphony.Core.TimeStampedEventArgs', @(h,d)onStarted(obj,h,d));
            function onStarted(obj, ~, ~)
                if obj.state.isPausing()
                    obj.tryCore(@()obj.cobj.RequestPause());
                elseif obj.state.isStopping()
                    obj.tryCore(@()obj.cobj.RequestStop());
                end
            end

            listeners(end + 1) = NetListener(obj.cobj, 'Stopped', 'Symphony.Core.TimeStampedEventArgs', @(h,d)onStopped(obj,h,d));
            function onStopped(obj, ~, ~)
                if obj.state.isRunning()
                    obj.state = symphonyui.core.ControllerState.STOPPING;
                end
            end

            listeners(end + 1) = NetListener(obj.cobj.DAQController, 'StartedHardware', 'Symphony.Core.TimeStampedEventArgs', @(h,d)onDaqControllerStartedHardware(obj, h, d));
            function onDaqControllerStartedHardware(obj, ~, ~)
                try
                    obj.currentProtocol.controllerDidStartHardware();
                catch ex
                    obj.requestStop();
                    rethrow(ex);
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

            try
                obj.process();
            catch x
                delete(listeners);
                rethrow(x);
            end

            delete(listeners);
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

            obj.currentProtocol.prepareEpoch(e);
            
            devices = obj.rig.getOutputDevices();
            for i = 1:numel(devices)
                d = devices{i};
                if ~e.hasStimulus(d) && ~e.hasBackground(d)
                    e.setBackground(d, d.background);
                end
            end
        end

        function e = nextInterval(obj)
            e = symphonyui.core.Epoch(class(obj.currentProtocol));
            e.shouldBePersisted = false;
            e.addKeyword(obj.INTERVAL_KEYWORD);

            obj.currentProtocol.prepareInterval(e);
            
            devices = obj.rig.getOutputDevices();
            for i = 1:numel(devices)
                d = devices{i};
                if ~e.hasStimulus(d) && ~e.hasBackground(d)
                    e.setBackground(d, d.background);
                end
            end
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
