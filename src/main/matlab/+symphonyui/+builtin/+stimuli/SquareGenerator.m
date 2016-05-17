classdef SquareGenerator < symphonyui.core.StimulusGenerator
    % Generates a square wave stimulus.
    
    properties
        preTime     % Leading duration (ms)
        stimTime    % Square wave duration (ms)
        tailTime    % Trailing duration (ms)
        amplitude   % Square wave amplitude (units)
        period      % Square wave period (ms)
        phase = 0   % Square wave phase offset (radians)
        mean        % Mean amplitude (units)
        sampleRate  % Sample rate of generated stimulus (Hz)
        units       % Units of generated stimulus
    end
    
    methods
        
        function obj = SquareGenerator(map)
            if nargin < 1
                map = containers.Map();
            end
            obj@symphonyui.core.StimulusGenerator(map);
        end
        
    end
    
    methods (Access = protected)
        
        function s = generateStimulus(obj)
            import Symphony.Core.*;
            
            timeToPts = @(t)(round(t / 1e3 * obj.sampleRate));
            
            prePts = timeToPts(obj.preTime);
            stimPts = timeToPts(obj.stimTime);
            tailPts = timeToPts(obj.tailTime);
            
            data = ones(1, prePts + stimPts + tailPts) * obj.mean;
            
            freq = 2 * pi / (obj.period * 1e-3);
            time = (0:stimPts-1) / obj.sampleRate;
            sine = sin(freq * time + obj.phase);
            
            square(sine > 0) = obj.amplitude;
            square(sine < 0) = -obj.amplitude;
            square = square + obj.mean;
            
            data(prePts + 1:prePts + stimPts) = square;
            
            parameters = obj.dictionaryFromMap(obj.propertyMap);
            measurements = Measurement.FromArray(data, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);
            
            cobj = RenderedStimulus(class(obj), parameters, output);
            s = symphonyui.core.Stimulus(cobj);
        end
        
    end
    
end

