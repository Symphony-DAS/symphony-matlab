classdef Sim < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = Sim()
            import symphonyui.builtin.devices.*;
            
            daq = symphonyui.builtin.daq.HekaSimulationDaqController();
            obj.daqController = daq;
            
            obj.devices = { ...
                GenericDevice('led1').bindStream(daq.getStream('ANALOG_OUT.0')), ...
            };
        end
        
    end
    
end

