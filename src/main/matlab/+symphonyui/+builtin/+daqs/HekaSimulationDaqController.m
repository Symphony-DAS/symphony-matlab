classdef HekaSimulationDaqController < symphonyui.builtin.daqs.SimulationDaqController
    % Manages a simulated HEKA (InstruTECH) DAQ interface (requires no attached hardware).

    methods

        function obj = HekaSimulationDaqController()
            for i = 1:16
                name = ['ai' num2str(i-1)];
                cstr = Symphony.Core.DAQInputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = 'V';
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end

            for i = 1:8
                name = ['ao' num2str(i-1)];
                cstr = Symphony.Core.DAQOutputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = 'V';
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end

            for i = 1:6
                name = ['diport' num2str(i-1)];
                cstr = Symphony.Core.DAQInputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = Symphony.Core.Measurement.UNITLESS;
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end

            for i = 1:6
                name = ['doport' num2str(i-1)];
                cstr = Symphony.Core.DAQOutputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = Symphony.Core.Measurement.UNITLESS;
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end

            Symphony.Core.Converters.Register(Symphony.Core.Measurement.UNITLESS, Symphony.Core.Measurement.UNITLESS, Symphony.Core.ConvertProcs.Scale(1, Symphony.Core.Measurement.UNITLESS));
            Symphony.Core.Converters.Register('V', 'V', Symphony.Core.ConvertProcs.Scale(1, 'V'));
            Symphony.Core.Converters.Register(Symphony.Core.Measurement.NORMALIZED, 'V', Symphony.Core.ConvertProcs.Scale(10.24, 'V'));
            Symphony.Core.Converters.Register('V', Symphony.Core.Measurement.NORMALIZED, Symphony.Core.ConvertProcs.Scale(1/10.24, Symphony.Core.Measurement.NORMALIZED));

            obj.sampleRate = symphonyui.core.Measurement(10000, 'Hz');
            obj.sampleRateType = symphonyui.core.PropertyType('denserealdouble', 'scalar', {1000, 10000, 20000, 50000});

            obj.simulationRunner = @symphonyui.builtin.stimulations.loopback;
        end

        function s = getStream(obj, name)
            s = getStream@symphonyui.core.DaqController(obj, name);
            if strncmp(name, 'd', 1)
                s = symphonyui.builtin.daqs.HekaSimulationDigitalDaqStream(s.cobj);
            end
        end

    end

    methods (Access = protected)

        function setSampleRate(obj, measurement)
            streams = obj.getStreams();
            for i = 1:numel(streams)
                streams{i}.sampleRate = measurement;
            end
            obj.cobj.SampleRate = measurement.cobj;
        end

    end

end
