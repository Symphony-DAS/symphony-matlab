classdef NiDaqController < symphonyui.core.DaqController
    % Manages a National Instruments DAQ interface
    
    methods
        
        function obj = NiDaqController(deviceName)
            NET.addAssembly(which('NIDAQInterface.dll'));
            
            if nargin < 1
                enum = Symphony.Core.EnumerableExtensions.Wrap(NI.NIDAQController.AvailableControllers());
                e = enum.GetEnumerator();
                if ~e.MoveNext()
                    error('Unable to find any National Instruments devices. Make sure your device is listed in NI MAX and try again.');
                end
                deviceName = char(e.Current().DeviceName);
            end
            
            cobj = NI.NIDAQController(deviceName);
            obj@symphonyui.core.DaqController(cobj);
            
            NI.NIDAQInputStream.RegisterConverters();
            NI.NIDAQOutputStream.RegisterConverters();
            
            obj.sampleRate = symphonyui.core.Measurement(10000, 'Hz');
            obj.sampleRateType = symphonyui.core.PropertyType('denserealdouble', 'scalar', {1000, 10000, 20000, 50000});

            obj.tryCore(@()obj.cobj.InitHardware());
        end
        
        function close(obj)
            close@symphonyui.core.DaqController(obj);
            obj.tryCore(@()obj.cobj.Dispose());
        end
        
        function s = getStream(obj, name)
            s = getStream@symphonyui.core.DaqController(obj, name);
            if strncmp(name, 'd', 1)
                s = symphonyui.builtin.daqs.NiDigitalDaqStream(s.cobj);
            end
        end
        
    end
    
end

