classdef LedPulse < symphonyui.core.Protocol
    
    properties
        led                             % Output LED
        preTime = 10                    % Pulse leading duration (ms)
        stimTime = 100                  % Pulse duration (ms)
        tailTime = 400                  % Pulse trailing duration (ms)
        lightAmplitude = 1              % Pulse amplitude (V)
        lightMean = 0
        amp                             % Input amplifier
        numberOfAverages = uint16(5)    % Number of epochs
        interpulseInterval = 0          % Duration between pulses (s)
    end
    
    properties (Hidden)
        ledType
        ampType
    end
    
    methods
        
        function onSetRig(obj)
            leds = cellfun(@(d)d.name, obj.rig.getDevices('LED'), 'UniformOutput', false);
            if isempty(leds)
                obj.led = [];
                obj.ledType = symphonyui.core.PropertyType('denserealdouble', 'empty');
            else
                obj.led = leds{1};
                obj.ledType = symphonyui.core.PropertyType('char', 'row', leds);
            end
            
            amps = cellfun(@(d)d.name, obj.rig.getDevices('Amp'), 'UniformOutput', false);
            if isempty(amps)
                obj.amp = [];
                obj.ampType = symphonyui.core.PropertyType('denserealdouble', 'empty');
            else
                obj.amp = amps{1};
                obj.ampType = symphonyui.core.PropertyType('char', 'row', amps);
            end
        end
        
        function [tf, msg] = isValid(obj)
            tf = numel(obj.rig.getDevices('LED')) > 0 && numel(obj.rig.getDevices('Amp')) > 0;
            msg = [];
            if ~tf
                msg = 'No LED or Amp device';
            end
        end
        
        function p = getPreview(obj, panel)
            p = symphonyui.builtin.previews.StimuliPreview(panel, @()createPreviewStimuli(obj));
            function s = createPreviewStimuli(obj)
                s = {obj.ledStimulus()};
            end
        end
        
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);
            
            obj.openFigure(symphonyui.builtin.figures.ResponseFigure(obj.rig.getDevice(obj.amp)));
        end
        
        function stim = ledStimulus(obj)
            p = symphonyui.builtin.stimuli.PulseGenerator();
            
            p.preTime = obj.preTime;
            p.stimTime = obj.stimTime;
            p.tailTime = obj.tailTime;
            p.amplitude = obj.lightAmplitude;
            p.mean = obj.lightMean;
            p.sampleRate = obj.sampleRate;
            p.units = obj.rig.getDevice(obj.led).background.displayUnits;
            
            stim = p.generate();
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
            epoch.addStimulus(obj.rig.getDevice(obj.led), obj.ledStimulus());
            epoch.addResponse(obj.rig.getDevice(obj.amp));
        end
        
        function tf = continuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < obj.numberOfAverages;
        end
        
        function tf = continueRun(obj)
            tf = obj.numEpochsCompleted < obj.numberOfAverages;
        end
        
    end
    
end

