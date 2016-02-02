classdef HekaAxopatch < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = HekaAxopatch()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = HekaDaqController();
            obj.daqController = daq;
            
            amp1 = AxopatchDevice('Amp1').bindStream(daq.getStream('ANALOG_OUT.0'));
            amp1.bindStream(daq.getStream('ANALOG_IN.0'), AxopatchDevice.SCALED_OUTPUT_STREAM_NAME);
            amp1.bindStream(daq.getStream('ANALOG_IN.1'), AxopatchDevice.GAIN_TELEGRAPH_STREAM_NAME);
            amp1.bindStream(daq.getStream('ANALOG_IN.2'), AxopatchDevice.MODE_TELEGRAPH_STREAM_NAME);
            obj.addDevice(amp1);
            
            amp2 = AxopatchDevice('Amp2').bindStream(daq.getStream('ANALOG_OUT.1'));
            amp2.bindStream(daq.getStream('ANALOG_IN.3'), AxopatchDevice.SCALED_OUTPUT_STREAM_NAME);
            amp2.bindStream(daq.getStream('ANALOG_IN.4'), AxopatchDevice.GAIN_TELEGRAPH_STREAM_NAME);
            amp2.bindStream(daq.getStream('ANALOG_IN.5'), AxopatchDevice.MODE_TELEGRAPH_STREAM_NAME);
            obj.addDevice(amp2);
            
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            green.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'0.3', '0.6', '1.2', '3.0', '4.0'}));
            green.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            obj.addDevice(green);
            
            blue = UnitConvertingDevice('Blue LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            blue.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'0.3', '0.6', '1.2', '3.0', '4.0'}));
            blue.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            obj.addDevice(blue);
            
            trigger1 = UnitConvertingDevice('Trigger1', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger1, 0);
            obj.addDevice(trigger1);
            
            trigger2 = UnitConvertingDevice('Trigger2', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger2, 2);
            obj.addDevice(trigger2);
        end
        
    end
    
end

