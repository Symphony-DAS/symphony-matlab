classdef Protocol < handle
    
    properties
        sampleRate = 10000;     % Acquisition sample rate (Hz)
    end
    
    properties (Hidden)
        sampleRateType = symphonyui.core.PropertyType('denserealdouble', 'scalar', {10000, 20000, 50000});
    end
    
    properties (Access = protected)
        rig
        persistor
        numEpochsPrepared
        numEpochsCompleted
        figureHandlerManager
    end
    
    methods
        
        function obj = Protocol()
            obj.figureHandlerManager = symphonyui.core.FigureHandlerManager();
        end
        
        function delete(obj)
            obj.closeFigures();
        end
        
        function setRig(obj, rig)
            obj.rig = rig;
            obj.onSetRig();
        end
        
        function onSetRig(obj) %#ok<MANU>
            
        end
        
        function setPersistor(obj, persistor)
            obj.persistor = persistor;
            obj.onSetPersistor();
        end
        
        function onSetPersistor(obj) %#ok<MANU>
            
        end
        
        function d = getPropertyDescriptors(obj)
            names = properties(obj);
            d = symphonyui.core.PropertyDescriptor.empty(0, numel(names));
            for i = 1:numel(names)
                d(i) = obj.getPropertyDescriptor(names{i});
            end
        end
        
        function d = getPropertyDescriptor(obj, name)
            d = symphonyui.core.PropertyDescriptor.fromProperty(obj, name);
        end
        
        function p = getPreview(obj, panel) %#ok<INUSD>
            p = [];
        end
        
        function prepareRun(obj)
            obj.numEpochsPrepared = 0;
            obj.numEpochsCompleted = 0;
            
            obj.rig.sampleRate = obj.sampleRate;
        end
        
        function prepareEpoch(obj, epoch) %#ok<INUSD>
            obj.numEpochsPrepared = obj.numEpochsPrepared + 1;
        end
        
        function completeEpoch(obj, epoch)
            obj.numEpochsCompleted = obj.numEpochsCompleted + 1;
            obj.figureHandlerManager.updateFigures(epoch);
        end
        
        function tf = continuePreparingEpochs(obj) %#ok<MANU>
            tf = false;
        end
        
        function tf = continueRun(obj) %#ok<MANU>
            tf = false;
        end
        
        function completeRun(obj) %#ok<MANU>
            
        end
        
        function closeFigures(obj)
            obj.figureHandlerManager.closeFigures();
        end

        function [tf, msg] = isValid(obj) %#ok<MANU>
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
