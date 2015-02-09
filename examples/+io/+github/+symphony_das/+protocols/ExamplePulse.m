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
        
        function p = getParameters(obj)
            import symphonyui.models.*;
            
            p = getParameters@symphonyui.models.Protocol(obj);
            
            p.findByName('amp').type = ParameterType('char', 'row', {'Amplifier_Ch1', 'Amplifier_Ch2'});
        end
        
    end
    
end

