classdef Pulse < symphonyui.core.Protocol
    
    properties
        amp = 'led1'                    % Output amplifier
        preTime = 50                    % Pulse leading duration (ms)
        stimTime = 500                  % Pulse duration (ms)
        tailTime = 50                   % Pulse trailing duration (ms)
        pulseAmplitude = 100            % Pulse amplitude (mV)
        preAndTailSignal = -60          % Mean signal (mV)
        numberOfAverages = uint16(5)    % Number of epochs
        interpulseInterval = 2          % Duration between pulses (s)
    end
    
    methods
        
        function stim = ampStimulus(obj)
            p = symphonyui.builtin.stimuli.PulseGenerator();
            
            p.preTime = obj.preTime;
            p.stimTime = obj.stimTime;
            p.tailTime = obj.tailTime;
            p.amplitude = obj.pulseAmplitude;
            p.mean = obj.preAndTailSignal;
            p.sampleRate = obj.sampleRate;
            p.units = obj.rig.getDevice(obj.amp).background.displayUnits;
            
            stim = p.generate();
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
            epoch.addStimulus(obj.rig.getDevice(obj.amp), obj.ampStimulus());
        end
        
        function tf = continuePreparingEpochs(obj)
            tf = true;
        end
        
        function tf = continueRun(obj)
            tf = true;
        end
        
    end
    
end

