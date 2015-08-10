classdef RigDescription < symphonyui.core.Description
    
    properties
        daqController
        devices
    end
    
    methods
        
        function obj = RigDescription()
            obj.devices = {};
        end
        
        function set.daqController(obj, c)
            obj.daqController = c;
        end
        
        function set.devices(obj, d)
            obj.devices = d;
        end
        
    end
    
end

