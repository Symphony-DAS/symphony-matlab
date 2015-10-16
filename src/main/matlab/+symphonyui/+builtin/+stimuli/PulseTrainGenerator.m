% Generates a rectangular pulse train stimulus.

classdef PulseTrainGenerator < symphonyui.core.StimulusGenerator
    
    properties
        preTime                     % Leading duration before the train (ms)
        pulseTime                   % Duration of each pulse in the train (ms)
        intervalTime                % Inter-pulse interval duration (ms)
        tailTime                    % Trailing duration after the train (ms)
        amplitude                   % Pulse amplitude (units)
        mean                        % Mean amplitude (units)
        numPulses                   % Number of pulses in the train
        pulseTimeIncrement = 0      % Amount to increment the pulse duration with every pulse in the train (ms)
        intervalTimeIncrement = 0   % Amount to increment the inter-pulse interval duration with every pulse in the train (ms)
        amplitudeIncrement = 0      % Amount to increment the pulse amplitude with every pulse in the train (units)
        sampleRate                  % Sample rate of generated stimulus (Hz)
        units                       % Units of generated stimulus
    end
    
    methods
        
        function obj = PulseTrainGenerator(map)
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
            data = ones(1, prePts) * obj.mean;
            for i = 0:obj.numPulses-1
                pulsePts = timeToPts(obj.pulseTimeIncrement * i + obj.pulseTime);
                pulse = ones(1, pulsePts) * obj.amplitudeIncrement * i + obj.amplitude + obj.mean;
                data = [data pulse]; %#ok<AGROW>
                
                if i < obj.numPulses-1
                    intervalPts = timeToPts(obj.intervalTimeIncrement * i + obj.intervalTime);
                    interval = ones(1, intervalPts) * obj.mean;
                    data = [data interval]; %#ok<AGROW>
                end
            end
            tailPts = timeToPts(obj.tailTime);
            tail = ones(1, tailPts) * obj.mean;
            data = [data tail];
            
            parameters = obj.dictionaryFromMap(obj.propertyMap);
            measurements = Measurement.FromArray(data, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);
            
            cobj = RenderedStimulus(class(obj), parameters, output);
            s = symphonyui.core.Stimulus(cobj);
        end
        
    end
    
end

