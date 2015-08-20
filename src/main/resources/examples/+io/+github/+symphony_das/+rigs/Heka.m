classdef Heka < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = Heka()
            import symphonyui.builtin.devices.*;
            
            daq = symphonyui.builtin.daqs.HekaDaqController();
            obj.daqController = daq;
            
            obj.devices = { ...
                GenericDevice('led1').bindStream(daq.getStream('ANALOG_OUT.0')), ...
            };
        end
        
    end
    
end

