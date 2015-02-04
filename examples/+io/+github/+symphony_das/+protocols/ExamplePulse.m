classdef ExamplePulse < symphonyui.models.Protocol
    
    properties (Constant)
        displayName = 'Example Pulse'
    end
    
    properties
        amp                             % Output device
        preTime = 50                    % Pulse leading duration (ms)
        stimTime = 500                  % Pulse duration (ms)
        tailTime = 50                   % Pulse trailing duration (ms)
        pulseAmplitude = 100            % Pulse amplitude (mV)
        preAndTailSignal = -60          % Mean signal (mV)
        numberOfAverages = uint16(5)    % Number of epochs
        interpulseInterval = 2          % Duration between pulses (s)
    end
    
    methods
        
        function p = parameters(obj)
            import symphonyui.models.*;
            
            p = parameters@symphonyui.models.Protocol(obj);
            
            p.amp.type = ParameterType('char', 'row', {'ab','cd','ef'});
            p.preTime.type.domain = [0 100];
            p.numberOfAverages.type.domain = [0 100];
            p.interpulseInterval.type.domain = {0 1 2};
        end
        
    end
    
end

