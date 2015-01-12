classdef Controller < handle
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    methods
        
        function obj = Controller()
            obj.state = SymphonyUI.Models.ControllerState.STOPPED;
        end
        
        function runProtocol(obj, protocol, experiment)
            disp('Run Protocol');
            obj.state = SymphonyUI.Models.ControllerState.RUNNING;
        end
        
        function run(obj, experiment)
            disp('Run');
            obj.state = SymphonyUI.Models.ControllerState.RUNNING;
        end
        
        function pause(obj)
            disp('Pause');
            obj.state = SymphonyUI.Models.ControllerState.PAUSING;
            pause(1);
            obj.state = SymphonyUI.Models.ControllerState.PAUSED;
        end
        
        function stop(obj)
            disp('Stop');
            obj.state = SymphonyUI.Models.ControllerState.STOPPING;
            pause(1);
            obj.state = SymphonyUI.Models.ControllerState.STOPPED;
        end
        
    end
    
end

