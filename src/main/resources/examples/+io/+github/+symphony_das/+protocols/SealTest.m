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
            import symphonyui.builtin.figures.*;
            
            prepareRun@symphonyui.core.Protocol(obj);
            
            obj.openFigure(ResponseFigureHandler(obj.rig.getDevice(obj.amp)));
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
        
        function tf = continuePreparingEpochs(obj)
            tf = true;
        end
        
        function tf = continueRun(obj)
            tf = true;
        end
        
    end
    
end

