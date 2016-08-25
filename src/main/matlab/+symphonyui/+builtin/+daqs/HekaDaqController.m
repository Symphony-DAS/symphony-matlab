classdef HekaDaqController < symphonyui.core.DaqController
    % Manages a HEKA (InstruTECH) DAQ interface (ITC-16, ITC-18, or ITC-1600).

    methods

        function obj = HekaDaqController(deviceType, deviceNumber)
            import symphonyui.builtin.daqs.HekaDeviceType;

            if nargin < 1
                deviceType = HekaDeviceType.USB18;
            end
            if nargin < 2
                deviceNumber = 0;
            end

            try
                NET.addAssembly(which('HekaDAQInterface.dll'));
                NET.addAssembly(which('HekaNativeInterop.dll'));
            catch x
                if strcmp(x.identifier, 'MATLAB:NET:CLRException:AddAssembly')
                    error(['Unable to load HEKA assemblies. Are you sure you have the HEKA drivers installed? ' ...
                        'If so, you may also try running MATLAB as Administrator to see if that fixes this problem.']);
                end
                rethrow(x);
            end

            switch deviceType
                case HekaDeviceType.ITC16
                    ctype = Heka.NativeInterop.ITCMM.ITC16_ID;
                case HekaDeviceType.ITC18
                    ctype = Heka.NativeInterop.ITCMM.ITC18_ID;
                case HekaDeviceType.ITC1600
                    ctype = Heka.NativeInterop.ITCMM.ITC1600_ID;
                case HekaDeviceType.ITC00
                    ctype = Heka.NativeInterop.ITCMM.ITC00_ID;
                case HekaDeviceType.USB16
                    ctype = Heka.NativeInterop.ITCMM.USB16_ID;
                case HekaDeviceType.USB18
                    ctype = Heka.NativeInterop.ITCMM.USB18_ID;
                otherwise
                    error('Unknown device type');
            end

            cobj = Heka.HekaDAQController(double(ctype), deviceNumber);
            obj@symphonyui.core.DaqController(cobj);

            Heka.HekaDAQInputStream.RegisterConverters();
            Heka.HekaDAQOutputStream.RegisterConverters();

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
            if strncmp(name, 'DIGITAL', 7)
                s = symphonyui.builtin.daqs.HekaDigitalDaqStream(s.cobj);
            end
        end

    end

end
