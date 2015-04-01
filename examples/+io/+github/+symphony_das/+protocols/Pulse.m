classdef Pulse < symphonyui.core.Protocol
    
    properties (Constant)
        displayName = 'Example Pulse'
        version = 1
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
        
        function p = getPropertyDescriptor(obj, name)
            p = uiextras.jide.PropertyDescriptor(name);
            switch name
                case {'displayName', 'version'}
                    p.Hidden = obj.preTime > 60;
                case 'amp'
                    %p.Domain = {'hi', 'wow'};
                    p.Category = num2str(obj.preTime);
                case {'preTime', 'tailTime'}
                    p.Category = 'Apple';
                    p.Domain = [50 70];
            end
        end
        
    end
    
end

