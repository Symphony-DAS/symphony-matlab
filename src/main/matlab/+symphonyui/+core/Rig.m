classdef Rig < handle
    
    properties
        daqController
    end
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    properties (SetAccess = private)
        isInitialized
        devices
    end
    
    methods
        
        function obj = Rig(description)
            obj.state = symphonyui.core.RigState.STOPPED;
            obj.isInitialized = false;
            obj.devices = {};
        end
        
        function initialize(obj)
            if obj.isInitialized
                return;
            end
            obj.isInitialized = true;
        end
        
        function close(obj)
            obj.isInitialized = false;
        end
        
        function addDevice(obj, device)
            obj.devices{end + 1} = device;
        end
        
        function record(obj, protocol, experiment)
            obj.state = symphonyui.core.RigState.RECORDING;
            disp(protocol);
            disp(experiment);
        end
        
        function viewOnly(obj, protocol)
            obj.state = symphonyui.core.RigState.VIEWING;
            disp(protocol);
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

