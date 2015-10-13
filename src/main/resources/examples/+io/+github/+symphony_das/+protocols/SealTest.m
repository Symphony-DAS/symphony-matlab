classdef SealTest < symphonyui.core.Protocol
    
    properties
        amp                             % Output amplifier
        preTime = 15                    % Pulse leading duration (ms)
        stimTime = 30                   % Pulse duration (ms)
        tailTime = 15                   % Pulse trailing duration (ms)
        pulseAmplitude = 5              % Pulse amplitude (mV)
    end
    
    properties (Hidden)
        ampType
    end
    
    methods
        
        function onSetRig(obj)
            onSetRig@symphonyui.core.Protocol(obj);
            
            amps = symphonyui.core.util.firstNonEmpty(obj.rig.getDeviceNames('Amp'), {'(None)'});
            obj.amp = amps{1};
            obj.ampType = symphonyui.core.PropertyType('char', 'row', amps);
        end
        
        function p = getPreview(obj, panel)
            p = symphonyui.builtin.previews.StimuliPreview(panel, @()createPreviewStimuli(obj));
            function s = createPreviewStimuli(obj)
                gen = symphonyui.builtin.stimuli.PulseGenerator(obj.ampStimulus().parameters);
                s = {gen.generate()};
            end
        end
        
        function stim = ampStimulus(obj)
            p = symphonyui.builtin.stimuli.RepeatingPulseGenerator();
            
            p.preTime = obj.preTime;
            p.stimTime = obj.stimTime;
            p.tailTime = obj.tailTime;
            p.amplitude = obj.pulseAmplitude;
            p.mean = obj.rig.getDevice(obj.amp).background.quantity;
            p.sampleRate = obj.sampleRate;
            p.units = obj.rig.getDevice(obj.amp).background.displayUnits;
            
            stim = p.generate();
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
            epoch.addStimulus(obj.rig.getDevice(obj.amp), obj.ampStimulus());
        end
        
        function tf = continuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < 1;
        end
        
        function tf = continueRun(obj)
            tf = obj.numEpochsCompleted < 1;
        end
        
    end
    
end

