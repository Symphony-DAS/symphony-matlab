classdef Pulse < symphonyui.core.Protocol
    
    properties (Constant)
        DISPLAY_NAME = 'Example Pulse'
        VERSION = 1
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
        
        function p = getParameter(obj, name)
            p = getParameter@symphonyui.core.Protocol(obj, name);
            
            switch name
                case 'name'
                    p.type = ParameterType('char', 'row', {'Amplifier_Ch1', 'Amplifier_Ch2'});
            end
        end
        
    end
    
end

