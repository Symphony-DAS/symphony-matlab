classdef Controller < handle
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    methods
        
        function obj = Controller()
            obj.state = symphonyui.models.ControllerState.STOPPED;
        end
        
        function runProtocol(obj, protocol)
            disp('Run');
            disp(protocol);
            obj.state = symphonyui.models.ControllerState.RUNNING;
        end
        
        function pause(obj)
            disp('Pause');
            obj.state = symphonyui.models.ControllerState.PAUSING;
            pause(1);
            obj.state = symphonyui.models.ControllerState.PAUSED;
        end
        
        function stop(obj)
            disp('Stop');
            obj.state = symphonyui.models.ControllerState.STOPPING;
            pause(1);
            obj.state = symphonyui.models.ControllerState.STOPPED;
        end
        
    end
    
end
