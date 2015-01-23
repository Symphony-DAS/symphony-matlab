classdef Controller < handle
    
    properties (SetObservable, SetAccess = private)
        state
        rig
    end
    
    methods
        
        function obj = Controller()
            obj.state = SymphonyUI.Models.ControllerState.NOT_READY;
        end
        
        function setRig(obj, rig)
            obj.rig = rig;
            obj.state = SymphonyUI.Models.ControllerState.STOPPED;
        end
        
        function enqueueProtocol(obj, protocol)
            error('Not implemented');
        end
        
        function runProtocol(obj, protocol)
            disp('Run Protocol');
            obj.state = SymphonyUI.Models.ControllerState.RUNNING;
        end
        
        function run(obj)
            error('Not implemented');
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
        
        function validateProtocol(obj, protocol)
            
        end
        
    end
    
end

