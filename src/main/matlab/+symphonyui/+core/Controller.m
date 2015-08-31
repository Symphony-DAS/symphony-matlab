classdef Controller < symphonyui.core.CoreObject
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    properties (Access = private)
        devices
        epochQueueDuration
        currentProtocol
    end
    
    properties (Constant, Access = private)
        PRELOAD_DURATION = seconds(3)
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
            import symphonyui.core.util.NetListener;
            
            obj.currentProtocol = protocol;
            
            listeners = NetListener.empty(0, 3);
            
            listeners(end + 1) = NetListener(obj.cobj, 'Started', 'Symphony.Core.TimeStampedEventArgs', @(h,d)onStarted(obj,h,d));
            function onStarted(obj, ~, ~)
                if ~obj.currentProtocol.continueRun()
                    obj.requestStop();
                end
            end
            
            listeners(end + 1) = NetListener(obj.cobj, 'RequestedStop', 'Symphony.Core.TimeStampedEventArgs', @(h,d)onRequestedStop(obj,h,d));
            function onRequestedStop(obj, ~, ~)
                obj.state = symphonyui.core.ControllerState.STOPPING;
            end
                        
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
            
            if isempty(persistor)
                obj.state = symphonyui.core.ControllerState.VIEWING;
            else
                obj.state = symphonyui.core.ControllerState.RECORDING;
            end
            
            try
                obj.process(persistor)
            catch x
                delete(listeners);
                obj.state = symphonyui.core.ControllerState.STOPPED;
                rethrow(x);
            end
            
            delete(listeners);
            obj.state = symphonyui.core.ControllerState.STOPPED;
        end
                
        function requestStop(obj)
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
    
    methods (Access = private)
        
        function addDevice(obj, device)
            obj.tryCore(@()obj.cobj.AddDevice(device.cobj));
        end
        
        function removeAllDevices(obj)
            obj.tryCore(@()obj.cobj.RemoveAllDevices());
        end
        
        function process(obj, persistor) 
            obj.clearEpochQueue();
            
            obj.currentProtocol.prepareRun();
            
            obj.preload();
            
            if ~isempty(persistor)
                parameters = containers.Map();
                meta = metaclass(obj.currentProtocol);
                for i = 1:numel(meta.Properties)
                    mpo = meta.Properties{i};
                    if mpo.Abstract || mpo.Hidden || ~strcmp(mpo.GetAccess, 'public');
                        continue;
                    end
                    parameters(mpo.Name) = obj.currentProtocol.(mpo.Name);
                end
                
                persistor.beginEpochBlock(class(obj.currentProtocol), parameters);
                endBlock = onCleanup(@()persistor.endEpochBlock());
            end
            
            task = obj.startAsync(persistor);
                        
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
            
            obj.currentProtocol.completeRun();
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

