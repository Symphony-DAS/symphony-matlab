classdef RepeatingPulseGenerator < symphonyui.core.StimulusGenerator
    % Generates a single rectangular pulse stimulus.
    
    properties
        preTime     % Leading duration (ms)
        stimTime    % Pulse duration (ms)
        tailTime    % Trailing duration (ms)
        amplitude   % Pulse amplitude (units)
        mean        % Mean amplitude (units)
        sampleRate  % Sample rate of generated stimulus (Hz)
        units       % Units of generated stimulus
    end
    
    methods
        
        function obj = RepeatingPulseGenerator(map)
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
            data(prePts + 1:prePts + stimPts) = obj.amplitude + obj.mean;
            
            parameters = obj.dictionaryFromMap(obj.propertyMap);
            measurements = Measurement.FromArray(data, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);
            
            cobj = RenderedStimulus(class(obj), parameters, output, TimeSpanOption.Indefinite);
            s = symphonyui.core.Stimulus(cobj);
        end
        
    end
    
end

