classdef Controller < symphonyui.core.CoreObject
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    properties (Access = private)
        devices
        epochQueueCount
        listeners
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
                d = devs{i};
                obj.addDevice(d);
                d.cobj.Clock = rig.daqController.cobj.Clock;
            end
        end
        
        function runProtocol(obj, protocol, persistor)            
            obj.bind(protocol);
            unbind = onCleanup(@()obj.unbind());
            
            protocol.prepareRun();
            
            task = obj.startAsync(persistor);
            
            try
                obj.process(protocol, persistor)
            catch x
                obj.stop();
                rethrow(x);
            end
            
            obj.stop();
            
            if task.IsFaulted
                error(char(task.Exception.Message));
            end
            
            protocol.completeRun();
        end
                
        function requestStop(obj)
            if obj.state == symphonyui.core.ControllerState.STOPPED
                return;
            end
            obj.tryCore(@()obj.cobj.RequestStop());
            obj.state = symphonyui.core.ControllerState.STOPPING;
        end
        
        function d = get.devices(obj)
            d = obj.cellArrayFromEnumerable(obj.cobj.Devices, @symphonyui.core.Device);
        end
        
        function c = get.epochQueueCount(obj)
            c = obj.cobj.EpochQueueCount;
        end
        
    end
    
    methods (Access = private)
        
        function process(obj, protocol, persistor)
            if ~isempty(persistor)
                persistor.beginEpochBlock(class(protocol));
            end
            
            try
                obj.processLoop(protocol);
            catch x
                if ~isempty(persistor)
                    persistor.endEpochBlock();
                end
                rethrow(x);
            end
            
            if ~isempty(persistor)
                persistor.endEpochBlock();
            end
        end
        
        function processLoop(obj, protocol)
            import symphonyui.core.ControllerState;
            
            while obj.state.isViewingOrRecording() && protocol.continueQueuing()
                epoch = symphonyui.core.Epoch(class(protocol));
                
                devs = obj.devices;
                for i = 1:numel(devs)
                    epoch.setBackground(devs{i}, devs{i}.background);
                end
                
                protocol.prepareEpoch(epoch);
                obj.enqueueEpoch(epoch);
                disp('q');
                
                while obj.state.isViewingOrRecording() && obj.epochQueueCount >= 6
                    pause(0.01);
                end
            end
            
            while obj.isRunning
                pause(0.01);
            end
            
            obj.waitForCompletedEpochTasks();
        end
        
        function addDevice(obj, device)
            obj.tryCore(@()obj.cobj.AddDevice(device.cobj));
        end
        
        function removeAllDevices(obj)
            obj.tryCore(@()obj.cobj.RemoveAllDevices());
        end
        
        function t = startAsync(obj, persistor)
            if isempty(persistor)
                cper = [];
            else
                cper = persistor.cobj;
            end
            t = obj.tryCoreWithReturn(@()obj.cobj.StartAsync(cper));
            if isempty(persistor)
                obj.state = symphonyui.core.ControllerState.VIEWING;
            else
                obj.state = symphonyui.core.ControllerState.RECORDING;
            end
        end
        
        function enqueueEpoch(obj, epoch)
            obj.tryCore(@()obj.cobj.EnqueueEpoch(epoch.cobj));
        end
        
        function clearEpochQueue(obj)
            obj.tryCore(@()obj.cobj.ClearEpochQueue());
        end
        
        function tf = isRunning(obj)
            tf = obj.cobj.IsRunning;
        end
        
        function stop(obj)
            obj.requestStop();
            while obj.isRunning
                pause(0.01);
            end
            obj.waitForCompletedEpochTasks();
            obj.state = symphonyui.core.ControllerState.STOPPED;
        end
        
        function waitForCompletedEpochTasks(obj)
            obj.tryCore(@()obj.cobj.WaitForCompletedEpochTasks());
        end
        
        function bind(obj, protocol)
            import symphonyui.core.util.NetListener;
            obj.listeners = {};
            obj.listeners{end + 1} = NetListener(obj.cobj, 'CompletedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @(h,d)obj.onCompletedEpoch(protocol, symphonyui.core.Epoch(d.Epoch)));            
            obj.listeners{end + 1} = NetListener(obj.cobj, 'DiscardedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @(h,d)obj.onDiscardedEpoch(protocol, symphonyui.core.Epoch(d.Epoch)));
        end
        
        function unbind(obj)
            while ~isempty(obj.listeners)
                delete(obj.listeners{1});
                obj.listeners(1) = [];
            end
        end
        
        function onCompletedEpoch(obj, protocol, epoch)
            protocol.completeEpoch(epoch);
            if ~protocol.continueRun()
                obj.requestStop();
            end
        end
        
        function onDiscardedEpoch(obj, protocol, epoch) %#ok<INUSD>
            obj.requestStop();
        end
        
    end
    
end

