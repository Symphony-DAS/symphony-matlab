classdef MultiClampDevice < symphonyui.core.Device
    % Represents a MultiClamp 700[A,B] device.
    
    methods
        
        function obj = MultiClampDevice(name, channel, serialNumber)            
            NET.addAssembly(which('Symphony.ExternalDevices.dll'));
            
            if nargin < 3
                enum = Symphony.Core.EnumerableExtensions.Wrap(Symphony.ExternalDevices.MultiClampDevice.AvailableSerialNumbers());
                e = enum.GetEnumerator();
                if ~e.MoveNext()
                    error(['Unable to find any MultiClamps. Make sure MultiClamp Commander is open and try again. ' ...
                        'If you are running MATLAB as Administrator, you may also need to run MultiClamp Commander ' ...
                        'as Administrator.']);
                end
                serialNumber = e.Current();
            end
            
            modes = NET.createArray('System.String', 3);
            modes(1) = 'VClamp';
            modes(2) = 'I0';
            modes(3) = 'IClamp';
            
            backgrounds = NET.createArray('Symphony.Core.IMeasurement', 3);
            backgrounds(1) = Symphony.Core.Measurement(0, 'mV');
            backgrounds(2) = Symphony.Core.Measurement(0, 'pA');
            backgrounds(3) = Symphony.Core.Measurement(0, 'pA');
            
            cobj = Symphony.ExternalDevices.MultiClampDevice(serialNumber, channel, Symphony.Core.SystemClock(), [], modes, backgrounds);
            cobj.Name = name;
            obj@symphonyui.core.Device(cobj);
        end
        
        function close(obj)
            close@symphonyui.core.Device(obj);
            obj.tryCore(@()obj.cobj.Dispose());
        end
        
        function m = getMode(obj)
            if obj.cobj.HasDeviceOutputParameters()
                m = char(obj.cobj.CurrentDeviceOutputParameters.Data.OperatingMode);
            elseif obj.cobj.HasDeviceInputParameters()
                m = char(obj.cobj.CurrentDeviceInputParameters.Data.OperatingMode);
            else
                error('Cannot get MultiClamp mode. Make sure MultiClamp Commander is open or try toggling the mode.');
            end
        end
        
    end
    
end

