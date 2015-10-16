% Generates a sine wave stimulus.

classdef SineGenerator < symphonyui.core.StimulusGenerator
    
    properties
        preTime     % Leading duration (ms)
        stimTime    % Sine wave duration (ms)
        tailTime    % Trailing duration (ms)
        amplitude   % Sine wave amplitude (units)
        period      % Sine wave period (ms)
        phase = 0   % Sine wave phase offset (radians)
        mean        % Mean amplitude (units)
        sampleRate  % Sample rate of generated stimulus (Hz)
        units       % Units of generated stimulus
    end
    
    methods
        
        function obj = SineGenerator(map)
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
            sine = obj.mean + obj.amplitude * sin(freq * time + obj.phase);
            
            data(prePts + 1:prePts + stimPts) = sine;
            
            parameters = obj.dictionaryFromMap(obj.propertyMap);
            measurements = Measurement.FromArray(data, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);
            
            cobj = RenderedStimulus(class(obj), parameters, output);
            s = symphonyui.core.Stimulus(cobj);
        end
        
    end
    
end

