classdef AxopatchDevice < symphonyui.core.Device
    
    properties (Constant)
        % These constants should directly reference Symphony.ExternalDevices but we cannot import the assembly before
        % the constants are assigned.
        SCALED_OUTPUT_STREAM_NAME = 'SCALED_OUTPUT' %char(Symphony.ExternalDevices.AxopatchDevice.SCALED_OUTPUT_STREAM_NAME)
        GAIN_TELEGRAPH_STREAM_NAME = 'GAIN_TELEGRAPH' %char(Symphony.ExternalDevices.AxopatchDevice.GAIN_TELEGRAPH_STREAM_NAME)
        MODE_TELEGRAPH_STREAM_NAME = 'MODE_TELEGRAPH' %char(Symphony.ExternalDevices.AxopatchDevice.MODE_TELEGRAPH_STREAM_NAME)
    end
    
    methods
        
        function obj = AxopatchDevice(name)
            NET.addAssembly(which('Symphony.ExternalDevices.dll'));
            
            modes = NET.createArray('System.String', 5);
            modes(1) = 'Track';
            modes(2) = 'VClamp';
            modes(3) = 'I0';
            modes(4) = 'IClampNormal';
            modes(5) = 'IClampFast';
            
            backgrounds = NET.createArray('Symphony.Core.IMeasurement', 5);
            backgrounds(1) = Symphony.Core.Measurement(0, 'mV');
            backgrounds(2) = Symphony.Core.Measurement(0, 'mV');
            backgrounds(3) = Symphony.Core.Measurement(0, 'pA');
            backgrounds(4) = Symphony.Core.Measurement(0, 'pA');
            backgrounds(5) = Symphony.Core.Measurement(0, 'pA');
            
            cobj = Symphony.ExternalDevices.AxopatchDevice(Symphony.ExternalDevices.Axopatch200B(), [], modes, backgrounds);
            cobj.Name = name;
            obj@symphonyui.core.Device(cobj);
        end
        
        function m = getMode(obj)
            try
                m = char(obj.cobj.CurrentDeviceParameters.OperatingMode);
            catch
                error('Cannot get Axopatch mode.');
            end
        end
        
    end
    
end

