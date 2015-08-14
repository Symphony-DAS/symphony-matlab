classdef RigDescription < symphonyui.core.Description
    
    properties
        daqController
        devices
        sampleRate
    end
    
    methods
        
        function obj = RigDescription()
            obj.daqController = symphonyui.builtin.daq.SimulationDaqController();
            obj.devices = {};
            obj.sampleRate = symphonyui.core.Measurement(10000, 'Hz');
        end
        
        function set.daqController(obj, c)
            validateattributes(c, {'symphonyui.core.DaqController'}, {'scalar'});
            obj.daqController = c;
        end
        
        function set.devices(obj, d)
            validateattributes(d, {'cell'}, {'2d'});
            obj.devices = d;
        end
        
        function set.sampleRate(obj, m)
            validateattributes(m, {'symphonyui.core.Measurement'}, {'scalar'});
            obj.sampleRate = m;
        end
        
    end
    
end

