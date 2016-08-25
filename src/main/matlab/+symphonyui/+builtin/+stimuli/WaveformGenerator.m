classdef WaveformGenerator < symphonyui.core.StimulusGenerator
    % Generates an arbitrary waveform stimulus from a specified vector. WaveformGenerator must store the entire waveform
    % vector with the stimulus in order be able to regenerate it (as opposed to just the parameters used to generate
    % it). Because of this, prefer using other stimulus generators, or writing your own, over using WaveformGenerator 
    % to avoid increasing the size of your data files.
    
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

