classdef SingleSpot < symphonyui.core.Protocol
    
    properties
        amp = 'Amp1'                    % Output amplifier
        preTime = 50                    % Spot leading duration (ms)
        stimTime = 500                  % Spot duration (ms)
        tailTime = 50                   % Spot trailing duration (ms)
        spotIntensity = 1.0             % Spot light intensity (0-1)
        spotDiameter = 300              % Spot diameter size (pixels)
        backgroundIntensity = 0.5       % Background light intensity (0-1)
        centerOffset = [0, 0]           % Spot [x, y] center offset (pixels)
        numberOfAverages = uint16(5)    % Number of epochs
    end
    
    properties (Hidden)
        ampType = symphonyui.core.PropertyType('char', 'row', {'Amp1', 'Amp2'});
    end
    
    methods
        
        function p = getPreview(obj, panel)
            p = symphonyui.builtin.previews.VisualStimuliPreview(panel, @()createPreviewStimuli(obj), @()obj.backgroundIntensity);
            function s = createPreviewStimuli(obj)
                s = {obj.spotStimulus()};
            end
        end
        
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);
            
            obj.openFigure(symphonyui.builtin.figures.ResponseFigure(obj.rig.getDevice(obj.amp)));
        end
        
        function spot = spotStimulus(obj)
            spot = Ellipse();
            spot.color = obj.spotIntensity;
            spot.radiusX = obj.spotDiameter/2;
            spot.radiusY = obj.spotDiameter/2;
            spot.position = [640, 480]/2 + obj.centerOffset;
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
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

