classdef Controller < symphonyui.core.CoreObject
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    properties (Access = private)
        listeners
        currentProtocol
        currentPersistor
    end
    
    methods
        
        function obj = Controller()
            cobj = Symphony.Core.Controller();
            obj@symphonyui.core.CoreObject(cobj);
            
            obj.state = symphonyui.core.ControllerState.STOPPED;
            
            obj.listeners = {};
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'Started', 'Symphony.Core.TimeStampedEventArgs', @obj.onStarted);
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'RequestedStop', 'Symphony.Core.TimeStampedEventArgs', @obj.onRequestedStop);
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'Stopped', 'Symphony.Core.TimeStampedEventArgs', @obj.onStopped);
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'CompletedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @obj.onCompletedEpoch);
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'DiscardedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @obj.onDiscardedEpoch);
        end
        
        function delete(obj)
            while ~isempty(obj.listeners)
                delete(obj.listeners{1});
                obj.listeners(1) = [];
            end
            disp('deleted controller');
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

            devices = rig.devices;
            for i = 1:numel(devices)
                d = devices{i};
                obj.addDevice(d);
                d.cobj.Clock = rig.daqController.cobj.Clock;
            end
        end
        
        function runProtocol(obj, protocol, persistor)
            obj.currentProtocol = protocol;
            obj.currentPersistor = persistor;
            
            protocol.prepareRun();
            
            task = obj.startAsync(persistor);
            
            while protocol.continueQueuing()
                epoch = symphonyui.core.Epoch(class(protocol));
                protocol.prepareEpoch(epoch);
                obj.enqueueEpoch(epoch);
            end

            while obj.isRunning
                pause(0.01);
            end
            
            protocol.completeRun();
        end
                
        function requestStop(obj)
            obj.tryCore(@()obj.cobj.RequestStop());
        end
        
    end
    
    methods (Access = private)
        
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
        end
        
        function enqueueEpoch(obj, epoch)
            obj.tryCore(@()obj.cobj.EnqueueEpoch(epoch.cobj));
        end
        
        function tf = isRunning(obj)
            tf = obj.cobj.isRunning;
        end
        
        function onStarted(obj, ~, ~)
            if isempty(obj.currentPersistor)
                obj.state = symphonyui.core.ControllerState.VIEWING;
            else
                obj.state = symphonyui.core.ControllerState.RECORDING;
            end
        end
        
        function onRequestedStop(obj, ~, ~)
            obj.state = symphonyui.core.ControllerState.STOPPING;
        end
        
        function onStopped(obj, ~, ~)
            obj.state = symphonyui.core.ControllerState.STOPPED;
        end
        
        function onCompletedEpoch(obj, ~, event)
            epoch = symphonyui.core.Epoch(event.Epoch);
            obj.currentProtocol.completeEpoch(epoch);
            if ~obj.currentProtocol.continueRun()
                obj.requestStop();
            end
        end
        
        function onDiscardedEpoch(obj, ~, ~)
            obj.requestStop();
        end
        
    end
    
end

