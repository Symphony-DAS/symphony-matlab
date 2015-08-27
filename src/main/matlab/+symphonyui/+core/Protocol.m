classdef Protocol < handle
    
    properties
        sampleRate = 10000;     % Acquisition sample rate (Hz)
    end
    
    properties (Access = protected)
        log
        rig
        numEpochsPrepared
        numEpochsCompleted
        figureHandlerManager
    end
    
    methods
        
        function obj = Protocol()
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.figureHandlerManager = symphonyui.core.FigureHandlerManager();
        end
        
        function setRig(obj, rig)
            obj.rig = rig;
        end
        
        function d = getPropertyDescriptors(obj)
            d = symphonyui.core.util.introspect(obj);
        end
        
        function prepareRun(obj)
            obj.numEpochsPrepared = 0;
            obj.numEpochsCompleted = 0;
            
            obj.rig.sampleRate = obj.sampleRate;
        end
        
        function prepareEpoch(obj, epoch)
            obj.numEpochsPrepared = obj.numEpochsPrepared + 1;
        end
        
        function completeEpoch(obj, epoch)
            obj.numEpochsCompleted = obj.numEpochsCompleted + 1;
            obj.figureHandlerManager.updateFigures(epoch);
        end
        
        function tf = continuePreloadingEpochs(obj)
            tf = obj.numEpochsPrepared < 6 && obj.continuePreparingEpochs();
        end
        
        function tf = continuePreparingEpochs(obj)
            tf = false;
        end
        
        function tf = continueRun(obj)
            tf = false;
        end
        
        function completeRun(obj)
            disp(['Num epochs prepared: ' num2str(obj.numEpochsPrepared)]);
            disp(['Num epochs completed: ' num2str(obj.numEpochsCompleted)]);
        end

        function [tf, msg] = isValid(obj)
            tf = true;
            msg = [];
        end
        
    end
    
    methods (Access = protected)
        
        function openFigure(obj, handler)
            obj.figureHandlerManager.openFigure(handler);
        end
        
    end

end
