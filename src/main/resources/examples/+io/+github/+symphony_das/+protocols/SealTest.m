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
            gen = symphonyui.builtin.stimuli.RepeatingPulseGenerator();
            
            gen.preTime = obj.preTime;
            gen.stimTime = obj.stimTime;
            gen.tailTime = obj.tailTime;
            gen.amplitude = obj.pulseAmplitude;
            gen.mean = obj.rig.getDevice(obj.amp).background.quantity;
            gen.sampleRate = obj.sampleRate;
            gen.units = obj.rig.getDevice(obj.amp).background.displayUnits;
            
            stim = gen.generate();
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

