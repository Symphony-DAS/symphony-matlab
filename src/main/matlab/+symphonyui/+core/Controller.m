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
        
        function runProtocol(obj, protocol, persistor)
            epochCompleted = symphonyui.core.util.NetListener(obj.cobj, 'CompletedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @onCompletedEpoch);
            deleteEpochCompleted = onCleanup(@()delete(epochCompleted));
            
            epochDiscarded = symphonyui.core.util.NetListener(obj.cobj, 'DiscardedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', @onDiscardedEpoch);
            deleteEpochDiscarded = onCleanup(@()delete(epochDiscarded));
        end
                
        function requestStop(obj)
            obj.tryCore(@()obj.cobj.RequestStop());
            obj.state = symphonyui.core.ControllerState.STOPPING;
        end
        
    end
    
end

