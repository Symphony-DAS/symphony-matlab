classdef Rig < handle
    
    properties (Constant, Abstract)
        displayName
    end
    
    properties (SetAccess = private)
        isInitialized
    end
    
    properties (Access = private)
        daq
    end
    
    methods
        
        function obj = Rig()
            obj.isInitialized = false;
        end
        
        function initialize(obj)
            obj.setup();
            obj.isInitialized = true;
        end
        
        function close(obj)
            obj.isInitialized = false;
        end
        
        function addDevice(obj, device)
            
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
    
    methods (Abstract)
        setup(obj);
    end
    
end

