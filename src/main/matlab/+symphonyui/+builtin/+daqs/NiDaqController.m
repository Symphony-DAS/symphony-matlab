classdef NiDaqController < symphonyui.core.DaqController
    % Manages a National Instruments DAQ interface.
    
    methods
        
        function obj = NiDaqController(deviceName)
            try
                NET.addAssembly(which('NIDAQInterface.dll'));
            catch x
                if strcmp(x.identifier, 'MATLAB:NET:CLRException:AddAssembly')
                    error(['Unable to load National Instruments assembly. Are you sure you have the NI-DAQmx drivers ' ...
                        'installed? Make sure you select "Custom" install during the NI-DAQmx setup process and ' ...
                        'choose to install ".NET Framework 4.5 Languages Support" in addition to the drivers.']);
                end
                rethrow(x);
            end
            
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
            
            Symphony.Core.Converters.Register(Symphony.Core.Measurement.UNITLESS, Symphony.Core.Measurement.UNITLESS, Symphony.Core.ConvertProcs.Scale(1, Symphony.Core.Measurement.UNITLESS));
            Symphony.Core.Converters.Register('V', 'V', Symphony.Core.ConvertProcs.Scale(1, 'V'));
            
            obj.sampleRate = symphonyui.core.Measurement(10000, 'Hz');
            obj.sampleRateType = symphonyui.core.PropertyType('denserealdouble', 'scalar', {1000, 10000, 20000, 50000});

            obj.tryCore(@()obj.cobj.InitHardware());
            
            Symphony.Core.Converters.Register(Symphony.Core.Measurement.NORMALIZED, 'V', Symphony.Core.ConvertProcs.Scale(-obj.cobj.MinAOVoltage, obj.cobj.MaxAOVoltage, 'V'));
            Symphony.Core.Converters.Register('V', Symphony.Core.Measurement.NORMALIZED, Symphony.Core.ConvertProcs.Scale(1/(-obj.cobj.MinAIVoltage), 1/obj.cobj.MaxAIVoltage, Symphony.Core.Measurement.NORMALIZED));
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

