classdef Heka < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = Heka()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            
            daq = HekaDaqController();
            
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0'));
            amp2 = MultiClampDevice('Amp2', 2).bindStream(daq.getStream('ANALOG_OUT.1')).bindStream(daq.getStream('ANALOG_IN.1'));
            
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            blue = UnitConvertingDevice('Blue LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            
            trigger1 = UnitConvertingDevice('Trigger1', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger1, 0);
            
            trigger2 = UnitConvertingDevice('Trigger2', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger2, 2);
            
            obj.daqController = daq;
            obj.devices = {amp1, amp2, green, blue, trigger1, trigger2};
        end
        
    end
    
end

