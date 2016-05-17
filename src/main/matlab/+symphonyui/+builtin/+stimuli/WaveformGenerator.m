classdef WaveformGenerator < symphonyui.core.StimulusGenerator
    % Generates an arbitrary waveform stimulus from a specified vector.
    
    properties
        waveshape   % Wave as a vector (units)
        sampleRate  % Sample rate of generated stimulus (Hz)
        units       % Units of generated stimulus
    end
    
    methods
        
        function obj = WaveformGenerator(map)
            if nargin < 1
                map = containers.Map();
            end
            obj@symphonyui.core.StimulusGenerator(map);
        end
        
    end
    
    methods (Access = protected)
        
        function s = generateStimulus(obj)
            import Symphony.Core.*;
            
            map = obj.propertyMap;
            map.remove('waveshape');
            parameters = obj.dictionaryFromMap(map);
            measurements = Measurement.FromArray(obj.waveshape, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);
            
            cobj = RenderedStimulus(class(obj), parameters, output);
            cobj.ShouldDataBePersisted = true;
            s = symphonyui.core.Stimulus(cobj);
        end
        
    end
    
end

