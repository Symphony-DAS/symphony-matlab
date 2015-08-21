classdef Heka < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = Heka()
            import symphonyui.builtin.devices.*;
            
            daq = symphonyui.builtin.daqs.HekaDaqController();
            obj.daqController = daq;
            
            obj.devices = { ...
                MultiClampDevice('amp', 1, 0).bindStream(daq.getStream('ANALOG_OUT.0')), ...
                GenericDevice('led1').bindStream(daq.getStream('ANALOG_OUT.1')), ...
            };
        end
        
    end
    
end

