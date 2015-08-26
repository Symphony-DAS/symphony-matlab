classdef Sim < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = Sim()
            import symphonyui.builtin.devices.*;
            
            daq = symphonyui.builtin.daqs.HekaSimulationDaqController();
            obj.daqController = daq;
            
            obj.devices = { ...
                MultiClampDevice('Amp', 1, 0).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0')), ...
                GenericDevice('Red LED').bindStream(daq.getStream('ANALOG_OUT.1')), ...
                GenericDevice('Green LED').bindStream(daq.getStream('ANALOG_OUT.2')), ...
                GenericDevice('Blue LED').bindStream(daq.getStream('ANALOG_OUT.3')), ...
                GenericDevice('Trigger').bindStream(daq.getStream('DIGITAL_OUT.0')), ...
            };
        end
        
    end
    
end

