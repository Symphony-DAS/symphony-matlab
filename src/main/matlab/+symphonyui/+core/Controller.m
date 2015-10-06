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
        PRELOAD_DURATION = seconds(3)
    end
    
    methods
        
        function obj = Controller()
            import symphonyui.core.util.NetListener;
            
            cobj = Symphony.Core.Controller();
            obj@symphonyui.core.CoreObject(cobj);
            
            obj.state = symphonyui.core.ControllerState.STOPPED;
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
            if obj.state == symphonyui.core.ControllerState.PAUSED
                error('Controller is paused');
            end
            
            onRunEnded = onCleanup(@()obj.endRun());
            obj.beginRun(protocol, persistor);
            
            obj.run();
        end
        
        function resume(obj)            
            if obj.state ~= symphonyui.core.ControllerState.PAUSED
                error('Controller not paused');
            end
            
            onRunEnded = onCleanup(@()obj.endRun());
            
            obj.run();
        end
        
        function requestPause(obj)
            obj.state = symphonyui.core.ControllerState.PAUSING;
            obj.tryCore(@()obj.cobj.RequestPause());
        end
                
        function requestStop(obj)
            if obj.state == symphonyui.core.ControllerState.PAUSED
                obj.state = symphonyui.core.ControllerState.STOPPED;
                obj.endRun();
                return;
            end
            obj.state = symphonyui.core.ControllerState.STOPPING;
            obj.tryCore(@()obj.cobj.RequestStop());
        end
        
        function d = get.devices(obj)
            d = obj.cellArrayFromEnumerable(obj.cobj.Devices, @symphonyui.core.Device);
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
                parameters = containers.Map();
                p = properties(protocol);
                for i = 1:numel(p)
                    parameters(p{i}) = protocol.(p{i});
                end
                persistor.beginEpochBlock(class(protocol), parameters);
            end
        end
        
        function endRun(obj)
            if obj.state == symphonyui.core.ControllerState.PAUSED
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
        end
        
        function removeAllDevices(obj)
            obj.tryCore(@()obj.cobj.RemoveAllDevices());
        end
        
        function run(obj)
            import symphonyui.core.util.NetListener;
            import symphonyui.core.ControllerState;
            
            listeners = NetListener.empty(0, 1);

            listeners(end + 1) = NetListener(obj.cobj, 'CompletedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @(h,d)onCompletedEpoch(obj,h,d));
            function onCompletedEpoch(obj, ~, event)
                epoch = symphonyui.core.Epoch(event.Epoch);
                obj.currentProtocol.completeEpoch(epoch);
                if ~obj.currentProtocol.continueRun()
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
            if obj.state == ControllerState.PAUSING
                obj.state = ControllerState.PAUSED;
            else
                obj.state = ControllerState.STOPPED;
            end
        end
        
        function process(obj)            
            obj.preload();
            
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
        
        function preload(obj)
            while obj.epochQueueDuration < obj.PRELOAD_DURATION
                if ~obj.state.isViewingOrRecording() || ~obj.currentProtocol.continuePreparingEpochs()
                    break;
                end
                epoch = obj.nextEpoch();
                obj.enqueueEpoch(epoch);
                drawnow();
            end
        end
        
        function processLoop(obj)
            while obj.currentProtocol.continuePreparingEpochs()
                if ~obj.state.isViewingOrRecording();
                    break;
                end
                epoch = obj.nextEpoch();
                obj.enqueueEpoch(epoch);
                while obj.epochQueueDuration > obj.PRELOAD_DURATION
                    if ~obj.state.isViewingOrRecording();
                        break;
                    end
                    pause(0.01);
                end
            end
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

