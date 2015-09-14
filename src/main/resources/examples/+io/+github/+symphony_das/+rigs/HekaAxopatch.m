classdef HekaAxopatch < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = HekaAxopatch()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            
            daq = HekaDaqController();
            
            amp1 = AxopatchDevice('Amp1').bindStream(daq.getStream('ANALOG_OUT.0'));
            amp1.bindStream(daq.getStream('ANALOG_IN.0'), AxopatchDevice.SCALED_OUTPUT_STREAM_NAME);
            amp1.bindStream(daq.getStream('ANALOG_IN.1'), AxopatchDevice.GAIN_TELEGRAPH_STREAM_NAME);
            amp1.bindStream(daq.getStream('ANALOG_IN.2'), AxopatchDevice.MODE_TELEGRAPH_STREAM_NAME);
            
            amp2 = AxopatchDevice('Amp2').bindStream(daq.getStream('ANALOG_OUT.1'));
            amp2.bindStream(daq.getStream('ANALOG_IN.3'), AxopatchDevice.SCALED_OUTPUT_STREAM_NAME);
            amp2.bindStream(daq.getStream('ANALOG_IN.4'), AxopatchDevice.GAIN_TELEGRAPH_STREAM_NAME);
            amp2.bindStream(daq.getStream('ANALOG_IN.5'), AxopatchDevice.MODE_TELEGRAPH_STREAM_NAME);
            
            green = CalibratedDevice('Green LED', symphonyui.core.Measurement.NORMALIZED, linspace(-1, 1), linspace(-1, 1)).bindStream(daq.getStream('ANALOG_OUT.2'));
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

