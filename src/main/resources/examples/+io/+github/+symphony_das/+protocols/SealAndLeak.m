classdef SealAndLeak < symphonyui.core.Protocol
    
    properties
        amp = 'Amp'                     % Output amplifier
        mode                            % 
        alternateMode = true            % Alternate mode on each successive run
        preTime = 15                    % Pulse leading duration (ms)
        stimTime = 30                   % Pulse duration (ms)
        tailTime = 15                   % Pulse trailing duration (ms)
        pulseAmplitude = 5              % Pulse amplitude (mV)
        leakAmpHoldSignal = -60         % 
    end
    
    methods
        
    end
    
end

