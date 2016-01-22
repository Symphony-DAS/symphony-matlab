classdef HekaMultiClamp < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = HekaMultiClamp()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = HekaDaqController();
            
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0'));
            amp2 = MultiClampDevice('Amp2', 2).bindStream(daq.getStream('ANALOG_OUT.1')).bindStream(daq.getStream('ANALOG_IN.1'));
            
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            green.addStaticConfigurationDescriptor(PropertyDescriptor('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'0.3', '0.6', '1.2', '3.0', '4.0'})));
            green.addStaticConfigurationDescriptor(PropertyDescriptor('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'})));
            
            blue = UnitConvertingDevice('Blue LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            blue.addStaticConfigurationDescriptor(PropertyDescriptor('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'0.3', '0.6', '1.2', '3.0', '4.0'})));
            blue.addStaticConfigurationDescriptor(PropertyDescriptor('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'})));
            
            trigger1 = UnitConvertingDevice('Trigger1', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger1, 0);
            
            trigger2 = UnitConvertingDevice('Trigger2', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger2, 2);
            
            obj.daqController = daq;
            obj.devices = {amp1, amp2, green, blue, trigger1, trigger2};
        end
        
    end
    
end

