classdef TwoAmp < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = TwoAmp()
            import symphonyui.builtin.devices.*;
            
            daq = symphonyui.builtin.daq.HekaDaqController();
            obj.daqController = daq;
            
            obj.devices = { ...
                GenericDevice('led1').bindStream(daq.getStream('ANALOG_OUT.0')), ...
                GenericDevice('led2').bindStream(daq.getStream('ANALOG_OUT.1')), ...
            };
        end
        
    end
    
end

