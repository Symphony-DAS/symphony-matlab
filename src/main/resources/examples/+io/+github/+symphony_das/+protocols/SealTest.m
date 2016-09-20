classdef SealTest < symphonyui.core.Protocol
    % Presents a set of infinitely repeating rectangular pulse stimuli to a specified amplifier. This protocol records
    % and displays no responses. Instead it assumes you have an oscilloscope attached to your rig with which you can
    % view the amplifier response.
    
    properties
        amp                             % Output amplifier
        preTime = 15                    % Pulse leading duration (ms)
        stimTime = 30                   % Pulse duration (ms)
        tailTime = 15                   % Pulse trailing duration (ms)
        pulseAmplitude = 5              % Pulse amplitude (mV or pA)
    end
    
    properties (Hidden)
        ampType
        statusFigure
    end
    
    methods
        
        function didSetRig(obj)
            didSetRig@symphonyui.core.Protocol(obj);
            
            [obj.amp, obj.ampType] = obj.createDeviceNamesProperty('Amp');
        end
        
        function p = getPreview(obj, panel)
            p = symphonyui.builtin.previews.StimuliPreview(panel, @()createPreviewStimuli(obj));
            function s = createPreviewStimuli(obj)
                gen = symphonyui.builtin.stimuli.PulseGenerator(obj.createAmpStimulus().parameters);
                s = gen.generate();
            end
        end
        
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);
            
            if isempty(obj.statusFigure) || ~isvalid(obj.statusFigure)
                obj.statusFigure = obj.showFigure('symphonyui.builtin.figures.CustomFigure', @null);
                f = obj.statusFigure.getFigureHandle();
                set(f, 'Name', 'Status');
                layout = uix.VBox('Parent', f);
                uix.Empty('Parent', layout);
                obj.statusFigure.userData.text = uicontrol( ...
                    'Parent', layout, ...
                    'Style', 'text', ...
                    'FontSize', 24, ...
                    'HorizontalAlignment', 'center', ...
                    'String', '');
                uix.Empty('Parent', layout);
                set(layout, 'Height', [-1 42 -1]);
            end
            
            if isvalid(obj.statusFigure)
                set(obj.statusFigure.userData.text, 'String', 'Running...');
            end
        end
        
        function stim = createAmpStimulus(obj)
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
            
            epoch.addStimulus(obj.rig.getDevice(obj.amp), obj.createAmpStimulus());
        end
        
        function tf = shouldContinuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < 1;
        end
        
        function tf = shouldContinueRun(obj)
            tf = obj.numEpochsCompleted < 1;
        end
        
        function completeRun(obj)
            completeRun@symphonyui.core.Protocol(obj);
            
            if isvalid(obj.statusFigure)
                set(obj.statusFigure.userData.text, 'String', 'Completed');
            end
        end
        
    end
    
end

