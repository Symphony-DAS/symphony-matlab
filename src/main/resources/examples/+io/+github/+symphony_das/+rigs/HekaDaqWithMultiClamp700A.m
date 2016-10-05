classdef HekaDaqWithMultiClamp700A < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = HekaDaqWithMultiClamp700A()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = HekaDaqController();
            obj.daqController = daq;
            
            amp1 = MultiClampDevice('Amp1', 1, [], []).bindStream(daq.getStream('ao0')).bindStream(daq.getStream('ai0'));
            obj.addDevice(amp1);
            
            amp2 = MultiClampDevice('Amp2', 2, [], []).bindStream(daq.getStream('ao1')).bindStream(daq.getStream('ai1'));
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
            
            % Digital streams represent digital ports not individual digital lines. A port is a collection of lines. A 
            % line is an individual signal that carries bit values (0s and 1s). To associate a device with a line you 
            % must first bind the device to the port (i.e. stream), and then associate the device with a bit position 
            % that signifies a line within the port. Note: The ITC-18 front panel digital lines are in [di/do]port1, 
            % not [di/do]port0.
            trigger1 = UnitConvertingDevice('Trigger1', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(trigger1, 0);
            obj.addDevice(trigger1);
            
            trigger2 = UnitConvertingDevice('Trigger2', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(trigger2, 2);
            obj.addDevice(trigger2);
        end
        
    end
    
end

