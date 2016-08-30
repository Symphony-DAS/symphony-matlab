classdef MultiClampDevice < symphonyui.core.Device
    % Represents a MultiClamp 700[A,B] device.
    
    methods
        
        function obj = MultiClampDevice(name, channel, serialNumberOrComPort, deviceNumber)            
            NET.addAssembly(which('Symphony.ExternalDevices.dll'));
            
            if nargin == 2
                type = '700B';
                serialNumber = [];
            elseif nargin == 3
                type = '700B';
                serialNumber = serialNumberOrComPort;
            elseif nargin == 4
                type = '700A';
                comPort = serialNumberOrComPort;
            end
            
            if (strcmp(type, '700A') && isempty(comPort)) || (strcmp(type, '700B') && isempty(serialNumber))
                enum = Symphony.Core.EnumerableExtensions.Wrap(Symphony.ExternalDevices.MultiClampDevice.AvailableSerialNumbers());
                e = enum.GetEnumerator();
                if ~e.MoveNext()
                    error(['Unable to find any MultiClamps. Make sure MultiClamp Commander is open and try again. ' ...
                        'If you are running MATLAB as Administrator, you may also need to run MultiClamp Commander ' ...
                        'as Administrator.']);
                end
                if strcmp(type, '700A')
                    bytes = uint32(e.Current);
                    comPort = bitand(bytes, hex2dec('000000FF'));
                    deviceNumber = bitand(bitshift(bytes, -8), hex2dec('000000FF'));
                else
                    serialNumber = e.Current();
                end
            end
            
            modes = NET.createArray('System.String', 3);
            modes(1) = 'VClamp';
            modes(2) = 'I0';
            modes(3) = 'IClamp';
            
            backgrounds = NET.createArray('Symphony.Core.IMeasurement', 3);
            backgrounds(1) = Symphony.Core.Measurement(0, 'mV');
            backgrounds(2) = Symphony.Core.Measurement(0, 'pA');
            backgrounds(3) = Symphony.Core.Measurement(0, 'pA');
            
            if strcmp(type, '700A')
                cobj = Symphony.ExternalDevices.MultiClampDevice(comPort, deviceNumber, channel, Symphony.Core.SystemClock(), [], modes, backgrounds);
            else
                cobj = Symphony.ExternalDevices.MultiClampDevice(serialNumber, channel, Symphony.Core.SystemClock(), [], modes, backgrounds);
            end
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

