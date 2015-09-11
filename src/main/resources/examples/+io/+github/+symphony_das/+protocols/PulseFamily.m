classdef PulseFamily < symphonyui.core.Protocol
    
    properties
        amp = 'Amp1'                    % Output amplifier
        preTime = 50                    % Pulse leading duration (ms)
        stimTime = 500                  % Pulse duration (ms)
        tailTime = 50                   % Pulse trailing duration (ms)
        firstPulseSignal = 100
        incrementPerPulse = 10
        pulsesInFamily = uint16(11)
        numberOfAverages = uint16(5)    % Number of families
        interpulseInterval = 0          % Duration between pulses (s)
    end
    
    properties (Hidden)
        ampType = symphonyui.core.PropertyType('char', 'row', {'Amp1', 'Amp2'});
    end
    
    methods
        
        function p = getPreview(obj, panel)
            p = symphonyui.builtin.previews.StimuliPreview(panel, @()createPreviewStimuli(obj));
            function s = createPreviewStimuli(obj)
                s = cell(1, obj.pulsesInFamily);
                for i = 1:numel(s)
                    s{i} = obj.ampStimulus(i);
                end
            end
        end
        
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);
            
            obj.openFigure(symphonyui.builtin.figures.ResponseFigure(obj.rig.getDevice(obj.amp)));
        end
        
        function [stim, pulseSignal] = ampStimulus(obj, pulseNum)
            pulseSignal = obj.incrementPerPulse * (double(pulseNum) - 1) + obj.firstPulseSignal;
            
            p = symphonyui.builtin.stimuli.PulseGenerator();
            
            p.preTime = obj.preTime;
            p.stimTime = obj.stimTime;
            p.tailTime = obj.tailTime;
            p.mean = obj.rig.getDevice(obj.amp).background.quantity;
            p.amplitude = pulseSignal - p.mean;
            p.sampleRate = obj.sampleRate;
            p.units = obj.rig.getDevice(obj.amp).background.displayUnits;
            
            stim = p.generate();
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
            pulseNum = mod(obj.numEpochsPrepared - 1, obj.pulsesInFamily) + 1;
            [stim, pulseSignal] = obj.ampStimulus(pulseNum);
            
            epoch.addParameter('pulseSignal', pulseSignal);
            epoch.addStimulus(obj.rig.getDevice(obj.amp), stim);
            epoch.addResponse(obj.rig.getDevice(obj.amp));
        end
        
        function tf = continuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < obj.numberOfAverages * obj.pulsesInFamily;
        end
        
        function tf = continueRun(obj)
            tf = obj.numEpochsCompleted < obj.numberOfAverages * obj.pulsesInFamily;
        end
        
    end
    
end

