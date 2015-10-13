classdef RigDescription < symphonyui.core.Description
    
    properties
        daqController
        devices
    end
    
    methods
        
        function obj = RigDescription()
            obj.daqController = symphonyui.builtin.daqs.SimulationDaqController();
            obj.devices = {};
        end
        
        function set.daqController(obj, c)
            validateattributes(c, {'symphonyui.core.DaqController'}, {'scalar'});
            obj.daqController = c;
        end
        
        function set.devices(obj, d)
            validateattributes(d, {'cell'}, {'2d'});
            obj.devices = d;
        end
        
    end
    
end

