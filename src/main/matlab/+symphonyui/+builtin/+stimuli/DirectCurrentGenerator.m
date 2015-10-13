% Generates a constant, zero-frequency, direct current stimulus.

classdef DirectCurrentGenerator < symphonyui.core.StimulusGenerator
    
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
        
        function set.time(obj, t)
            if t <= 0
                error('Stimulus time must be greater than 0');
            end
            obj.time = t;
        end
        
    end
    
    methods (Access = protected)
        
        function s = generateStimulus(obj)
            import Symphony.Core.*;
            
            timeToPts = @(t)(round(t * obj.sampleRate));
            
            pts = timeToPts(obj.time);
            
            data = ones(1, pts) * obj.offset;
            
            parameters = obj.dictionaryFromMap(obj.propertyMap);
            measurements = Measurement.FromArray(data, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);
            
            cobj = RenderedStimulus(class(obj), parameters, output);
            s = symphonyui.core.Stimulus(cobj);
        end
        
    end
    
end

