classdef Controller < symphonyui.core.CoreObject
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    methods
        
        function obj = Controller()
            cobj = Symphony.Core.Controller();
            obj@symphonyui.core.CoreObject(cobj);
            
            obj.state = symphonyui.core.ControllerState.STOPPED;
        end
        
        function setRig(obj, rig)
            obj.tryCore(@()obj.cobj.RemoveAllDevices());
            obj.cobj.DAQController = [];
            if isempty(rig)
                return;
            end

            obj.cobj.DAQController = rig.daqController.cobj;
            obj.cobj.Clock = rig.daqController.cobj.Clock;

            devices = rig.devices;
            for i = 1:numel(devices)
                obj.tryCore(@()obj.cobj.AddDevice(devices{i}.cobj));
                devices{i}.cobj.Clock = rig.daqController.cobj.Clock;
            end
        end
        
        function runProtocol(obj, protocol, persistor)
            epochCompleted = symphonyui.core.util.NetListener(obj.cobj, 'CompletedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @onCompletedEpoch);
            deleteEpochCompleted = onCleanup(@()delete(epochCompleted));
            
            epochDiscarded = symphonyui.core.util.NetListener(obj.cobj, 'DiscardedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @onDiscardedEpoch);
            deleteEpochDiscarded = onCleanup(@()delete(epochDiscarded));
            
            if isempty(persistor)
                obj.state = symphonyui.core.ControllerState.VIEWING;
            else
                obj.state = symphonyui.core.ControllerState.RECORDING;
            end
            pause(1);
            obj.state = symphonyui.core.ControllerState.STOPPED;
        end
                
        function requestStop(obj)
            obj.tryCore(@()obj.cobj.RequestStop());
            obj.state = symphonyui.core.ControllerState.STOPPING;
        end
        
    end
    
end

