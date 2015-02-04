classdef Controller < handle
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    methods
        
        function obj = Controller()
            obj.state = symphonyui.models.ControllerState.STOPPED;
        end
        
        function runProtocol(obj, protocol)
            [valid, msg] = obj.validateProtocol(protocol);
            if ~valid
                error(msg);
            end
            
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
        
        function [tf, msg] = validateProtocol(obj, protocol)
            [tf, msg] = protocol.isValid;
        end
        
    end
    
end

