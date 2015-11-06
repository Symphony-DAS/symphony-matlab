classdef HekaSimulationDaqController < symphonyui.builtin.daqs.SimulationDaqController

    methods

        function obj = HekaSimulationDaqController()
            for i = 1:16
                name = ['ANALOG_IN.' num2str(i-1)];
                cstr = Symphony.Core.DAQInputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = 'V';
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end

            for i = 1:8
                name = ['ANALOG_OUT.' num2str(i-1)];
                cstr = Symphony.Core.DAQOutputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = 'V';
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end

            for i = 1:6
                name = ['DIGITAL_IN.' num2str(i-1)];
                cstr = Symphony.Core.DAQInputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = Symphony.Core.Measurement.UNITLESS;
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end

            for i = 1:6
                name = ['DIGITAL_OUT.' num2str(i-1)];
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

            obj.simulationRunner = @(output, timeStep)obj.loopbackRunner(output, timeStep);
        end

        function s = getStream(obj, name)
            s = getStream@symphonyui.core.DaqController(obj, name);
            if strncmp(name, 'DIGITAL', 7)
                s = symphonyui.builtin.daqs.HekaSimulationDigitalDaqStream(s.cobj);
            end
        end

    end

    methods (Access = private)

        function input = loopbackRunner(obj, output, timeStep)
            import Symphony.Core.*;

            % Create the input Dictionary to return.
            input = NET.createGeneric('System.Collections.Generic.Dictionary', ...
                {'Symphony.Core.IDAQInputStream', 'Symphony.Core.IInputData'});

            % Get all input streams (i.e. channels) associated with the DAQ controller.
            inputStreams = NET.invokeGenericMethod('System.Linq.Enumerable', 'ToList', ...
                {'Symphony.Core.IDAQInputStream'}, obj.cobj.InputStreams);

            % Loop through all input streams.
            inStreamEnum = inputStreams.GetEnumerator();
            while inStreamEnum.MoveNext()
                inStream = inStreamEnum.Current;
                inData = [];

                if ~inStream.Active
                    % We don't care to process inactive input streams (i.e. channels without devices).
                    continue;
                end

                % Find the corresponding output data and make it into input data.
                outStreamEnum = output.Keys.GetEnumerator();
                while outStreamEnum.MoveNext()
                    outStream = outStreamEnum.Current;

                    if strcmp(char(outStream.Name), strrep(char(inStream.Name), '_IN.', '_OUT.'))
                        outData = output.Item(outStream);
                        inData = InputData(outData.Data, outData.SampleRate, obj.cobj.Clock.Now);
                        break;
                    end
                end

                % If there was no corresponding output, simulate noise.
                if isempty(inData)
                    samples = Symphony.Core.TimeSpanExtensions.Samples(timeStep, inStream.SampleRate);
                    noise = Measurement.FromArray(rand(1, samples) - 0.5, 'mV');
                    inData = InputData(noise, inStream.SampleRate, obj.cobj.Clock.Now);
                end

                input.Add(inStream, inData);
            end
        end

    end

    methods (Access = protected)

        function setSampleRate(obj, measurement)
            streams = obj.streams;
            for i = 1:numel(streams)
                streams{i}.sampleRate = measurement;
            end
            obj.cobj.SampleRate = measurement.cobj;
        end

    end

end
