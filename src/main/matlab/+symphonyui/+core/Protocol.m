classdef Protocol < handle
    
    properties
        sampleRate  % Acquisition sample rate (Hz)
    end
    
    properties (Hidden)
        sampleRateType
    end
    
    properties (Access = protected)
        rig
        persistor
        numEpochsPrepared
        numEpochsCompleted
        numIntervalsPrepared
        numIntervalsCompleted
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
        
        function onSetRig(obj)
            rate = obj.rig.sampleRate;
            if isempty(rate)
                obj.sampleRate = [];
            else
                obj.sampleRate = rate.quantityInBaseUnits;
            end
            obj.sampleRateType = obj.rig.sampleRateType;
        end
        
        function setPersistor(obj, persistor)
            obj.persistor = persistor;
            obj.onSetPersistor();
        end
        
        function onSetPersistor(obj) %#ok<MANU>
            
        end
        
        function applyPreset(obj, preset)
            descriptors = obj.getPropertyDescriptors();
            names = preset.propertyMap.keys;
            for i = 1:numel(names)
                d = descriptors.findByName(names{i});
                v = preset.propertyMap(names{i});
                if ~isempty(d) && d.type.canAccept(v)
                    obj.(names{i}) = v;
                end
            end
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
            obj.clearFigures();
            
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
        
        function prepareInterval(obj, interval) %#ok<INUSD>
            obj.numIntervalsPrepared = obj.numIntervalsPrepared + 1;
        end
        
        function completeInterval(obj, interval) %#ok<INUSD>
            obj.numIntervalsCompleted = obj.numIntervalsCompleted + 1;
        end
        
        function tf = continuePreparingEpochs(obj) %#ok<MANU>
            tf = false;
        end
        
        function tf = continueRun(obj) %#ok<MANU>
            tf = false;
        end
        
        function completeRun(obj) %#ok<MANU>
            
        end
        
        function clearFigures(obj)
            obj.figureHandlerManager.clearFigures();
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
        
        function showFigure(obj, className, varargin)
            obj.figureHandlerManager.showFigure(className, varargin{:});
        end
        
    end

end
