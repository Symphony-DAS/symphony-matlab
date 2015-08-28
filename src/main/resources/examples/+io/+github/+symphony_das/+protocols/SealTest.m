classdef SealTest < symphonyui.core.Protocol
    
    properties
        amp = 'Amp1'                    % Output amplifier
        preTime = 15                    % Pulse leading duration (ms)
        stimTime = 30                   % Pulse duration (ms)
        tailTime = 15                   % Pulse trailing duration (ms)
        pulseAmplitude = 5              % Pulse amplitude (mV)
    end
    
    properties (Hidden)
        ampType = symphonyui.core.PropertyType('char', 'row', {'Amp1', 'Amp2'});
        modeType = symphonyui.core.PropertyType('char', 'row', {'Seal', 'Leak'})
    end
    
    methods
        
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);
            
            disp(obj);
        end
        
    end
    
end

