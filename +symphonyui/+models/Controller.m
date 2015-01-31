classdef Controller < handle
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    properties (SetAccess = private)
        protocol
    end
    
    methods
        
        function obj = Controller()
            obj.state = symphonyui.models.ControllerState.STOPPED;
        end
        
        function setProtocol(obj, p)
            if obj.state ~= symphonyui.models.ControllerState.STOPPED
                error('Controller must be stopped to set protocol');
            end
            obj.protocol = p;
        end
        
        function run(obj)
            [valid, msg] = obj.isValid();
            if ~valid
                error(msg);
            end
            
            disp('Run');
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
        
        function [tf, msg] = isValid(obj)
            if isempty(obj.protocol)
                tf = false;
                msg = 'Controller has no protocol';
                return;
            end
            
            [tf, msg] = obj.protocol.isValid;
        end
        
    end
    
end

