classdef DirectCurrentGenerator < symphonyui.core.StimulusGenerator
    % Generates a constant, zero-frequency, direct current stimulus.

    properties
        time        % Duration (s)
        offset      % Mean value (units)
        sampleRate  % Sample rate of generated stimulus (Hz)
        units       % Units of generated stimulus
    end

    methods

        function obj = DirectCurrentGenerator(map)
            if nargin < 1
                map = containers.Map();
            end
            obj@symphonyui.core.StimulusGenerator(map);
        end

    end

    methods (Access = protected)

        function s = generateStimulus(obj)
            import Symphony.Core.*;

            timeToPts = @(t)(round(t * obj.sampleRate));

            pts = timeToPts(obj.time);

            % Allows the RenderedStimulus to determine the BaseUnits of the output when the duration is zero. The
            % duration (span) is being explicitly declared below so a zero duration stimulus will truely be of duration
            % zero even though it has one data point.
            pts = max(pts, 1);

            data = ones(1, pts) * obj.offset;

            parameters = obj.dictionaryFromMap(obj.propertyMap);
            measurements = Measurement.FromArray(data, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);
            span = TimeSpanOption(System.TimeSpan.FromTicks(obj.time * 1e7));

            cobj = RenderedStimulus(class(obj), parameters, output, span);
            s = symphonyui.core.Stimulus(cobj);
        end

    end

end
