classdef Pulse < symphonyui.core.Protocol
    
    properties
        amp                             % Output amplifier
        preTime = 50                    % Pulse leading duration (ms)
        stimTime = 500                  % Pulse duration (ms)
        tailTime = 50                   % Pulse trailing duration (ms)
        pulseAmplitude = 100            % Pulse amplitude (mV)
        numberOfAverages = uint16(5)    % Number of epochs
        interpulseInterval = 0          % Duration between pulses (s)
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
                s = {obj.ampStimulus()};
            end
        end
        
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);
            
            obj.openFigure(symphonyui.builtin.figures.ResponseFigure(obj.rig.getDevice(obj.amp)));
        end
        
        function stim = ampStimulus(obj)
            p = symphonyui.builtin.stimuli.PulseGenerator();
            
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
            epoch.addResponse(obj.rig.getDevice(obj.amp));
        end
        
        function prepareInterval(obj, interval)
            prepareInterval@symphonyui.core.Protocol(obj, interval);
            
            if obj.interpulseInterval > 0
                device = obj.rig.getDevice(obj.amp);
                interval.addDirectCurrentStimulus(device, device.background, obj.interpulseInterval, obj.sampleRate);
            end
        end
        
        function tf = continuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < obj.numberOfAverages;
        end
        
        function tf = continueRun(obj)
            tf = obj.numEpochsCompleted < obj.numberOfAverages;
        end
        
    end
    
end

