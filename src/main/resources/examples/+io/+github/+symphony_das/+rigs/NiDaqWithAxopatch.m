classdef NiDaqWithAxopatch < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = NiDaqWithAxopatch()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = NiDaqController();
            obj.daqController = daq;
            
            amp1 = AxopatchDevice('Amp1').bindStream(daq.getStream('ao0'));
            amp1.bindStream(daq.getStream('ai0'), AxopatchDevice.SCALED_OUTPUT_STREAM_NAME);
            amp1.bindStream(daq.getStream('ai1'), AxopatchDevice.GAIN_TELEGRAPH_STREAM_NAME);
            amp1.bindStream(daq.getStream('ai2'), AxopatchDevice.MODE_TELEGRAPH_STREAM_NAME);
            obj.addDevice(amp1);
            
            amp2 = AxopatchDevice('Amp2').bindStream(daq.getStream('ao1'));
            amp2.bindStream(daq.getStream('ai3'), AxopatchDevice.SCALED_OUTPUT_STREAM_NAME);
            amp2.bindStream(daq.getStream('ai4'), AxopatchDevice.GAIN_TELEGRAPH_STREAM_NAME);
            amp2.bindStream(daq.getStream('ai5'), AxopatchDevice.MODE_TELEGRAPH_STREAM_NAME);
            obj.addDevice(amp2);
            
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ao2'));
            green.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'0.3', '0.6', '1.2', '3.0', '4.0'}));
            green.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            obj.addDevice(green);
            
            blue = UnitConvertingDevice('Blue LED', 'V').bindStream(daq.getStream('ao3'));
            blue.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'0.3', '0.6', '1.2', '3.0', '4.0'}));
            blue.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            obj.addDevice(blue);
            
            trigger1 = UnitConvertingDevice('Trigger1', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('doport0'));
            daq.getStream('doport0').setBitPosition(trigger1, 0);
            obj.addDevice(trigger1);
            
            trigger2 = UnitConvertingDevice('Trigger2', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('doport0'));
            daq.getStream('doport0').setBitPosition(trigger2, 2);
            obj.addDevice(trigger2);
        end
        
    end
    
end

