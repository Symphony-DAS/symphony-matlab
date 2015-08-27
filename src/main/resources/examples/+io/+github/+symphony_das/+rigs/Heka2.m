classdef Heka2 < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = Heka2()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            
            daq = HekaDaqController();
            
            amp = MultiClampDevice('Amp', 1).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0'));
            
            red = UnitConvertingDevice('Red LED', 'V').bindStream(daq.getStream('ANALOG_OUT.1'));
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            blue = UnitConvertingDevice('Blue LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            
            trigger1 = UnitConvertingDevice('Trigger1', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger1, 0);
            
            trigger2 = UnitConvertingDevice('Trigger2', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger2, 2);
            
            obj.daqController = daq;
            obj.devices = {amp, red, green, blue, trigger1, trigger2};
        end
        
    end
    
end

