classdef Controller < handle
    
    properties (SetObservable, SetAccess = private)
        state
        rig
    end
    
    methods
        
        function obj = Controller()
            obj.state = symphonyui.models.ControllerState.STOPPED;
        end
        
        function setRig(obj, rig)
            if obj.state ~= symphonyui.models.ControllerState.STOPPED
                error('Cannot set rig until the controller is stopped');
            end
            
            obj.rig = rig;
            obj.state = symphonyui.models.ControllerState.STOPPED;
        end
        
        function enqueueProtocol(obj, protocol)
            error('Not implemented');
        end
        
        function runProtocol(obj, protocol)
            disp('Run Protocol');
            obj.state = symphonyui.models.ControllerState.RUNNING;
        end
        
        function run(obj)
            error('Not implemented');
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
        
        function validateProtocol(obj, protocol)
            
        end
        
    end
    
end

