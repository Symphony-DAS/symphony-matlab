classdef RigDescription < symphonyui.core.Description
    
    properties
        daqController
    end
    
    properties (SetAccess = private)
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
        
        function addDevice(obj, device)
            validateattributes(device, {'symphonyui.core.Device'}, {'scalar'});
            obj.devices{end + 1} = device;
        end
        
    end
    
end

