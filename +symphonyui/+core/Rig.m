classdef Rig < handle
    
    events (NotifyAccess = private)
        Initialized
        Closed
    end
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    properties (SetAccess = private)
        isInitialized
    end
    
    properties (Access = private)
        controller
    end
    
    methods
        
        function obj = Rig()
            obj.isInitialized = false;
            obj.state = symphonyui.core.RigState.STOPPED;
        end
        
        function initialize(obj)
            if obj.isInitialized
                return;
            end
            obj.isInitialized = true;
            notify(obj, 'Initialized');
        end
        
        function close(obj)
            obj.isInitialized = false;
            notify(obj, 'Closed');
        end
        
        function addDevice(obj, device)
            
        end
        
        function record(obj, protocol, experiment)
            obj.state = symphonyui.core.RigState.RECORDING;
            disp(protocol);
            disp(experiment);
        end
        
        function preview(obj, protocol)
            obj.state = symphonyui.core.RigState.PREVIEWING;
            disp(protocol);
        end
        
        function pause(obj)
            obj.state = symphonyui.core.RigState.PAUSED;
        end
        
        function stop(obj)
            obj.state = symphonyui.core.RigState.STOPPED;
        end
        
        function [tf, msg] = isValid(obj)
            if ~obj.isInitialized
                tf = false;
                msg = 'Rig is not initialized';
                return;
            end
            tf = true;
            msg = [];
        end
        
    end
    
end

