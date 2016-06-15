classdef RigDescription < symphonyui.core.Description
    % A RigDescription describes the devices in an electrophysiology setup. In a typical setup, each amplifier channel, 
    % any stimulation or monitoring devices (such as an LED, valve, temperature controller, light meter, etc.) is 
    % represented by a distinct device within a RigDescription.
    %
    % To write a new description:
    %   1. Subclass RigDescription
    %   2. Set the DAQ controller
    %   3. Add devices
    %   4. Bind devices
    %
    % RigDescription Methods:
    %   addDevice   - Adds a device to this description
    
    properties
        daqController   % DAQ controller assigned to this description
    end
    
    properties (SetAccess = private)
        devices     % Cell array of devices added to this description
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
            % Adds a device to this description
            
            validateattributes(device, {'symphonyui.core.Device'}, {'scalar'});
            obj.devices{end + 1} = device;
        end
        
        function removeDevice(obj, device)
            % Removes a device from this description
            
            i = cellfun(@(d)d == device, obj.devices);
            obj.devices(i) = [];
        end
        
    end
    
end

