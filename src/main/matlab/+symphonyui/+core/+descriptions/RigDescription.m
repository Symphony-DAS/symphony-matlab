classdef RigDescription < symphonyui.core.Description
    % A RigDescription describes the devices in an electrophysiology setup. In a typical setup, each amplifier channel, 
    % any stimulation or monitoring devices (such as an LED, valve, temperature controller, light meter, etc.) is 
    % represented by a distinct device within a RigDescription.
    %
    % To write a new rig description you must subclass the RigDescription class. 
    
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

