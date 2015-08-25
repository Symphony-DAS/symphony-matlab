classdef Heka2 < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = Heka2()
            import symphonyui.builtin.devices.*;
            
            daq = symphonyui.builtin.daqs.HekaDaqController();
            obj.daqController = daq;
            
            obj.devices = { ...
                MultiClampDevice('Amp', 1, 0).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0')), ...
                GenericDevice('Red LED').bindStream(daq.getStream('ANALOG_OUT.1')), ...
                GenericDevice('Green LED').bindStream(daq.getStream('ANALOG_OUT.2')), ...
                GenericDevice('Blue LED').bindStream(daq.getStream('ANALOG_OUT.3')), ...
            };
        end
        
    end
    
end

