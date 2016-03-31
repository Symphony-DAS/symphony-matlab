classdef Protocol < handle

    properties
        sampleRate  % Acquisition sample rate (Hz)
    end

    properties (Hidden)
        sampleRateType
    end

    properties (Access = protected)
        numEpochsPrepared
        numEpochsCompleted
        numIntervalsPrepared
        numIntervalsCompleted
        figureHandlerManager
    end

    properties (Access = protected, Transient)
        rig
        persistor
    end

    methods

        function obj = Protocol()
            obj.figureHandlerManager = symphonyui.core.FigureHandlerManager();
        end

        function delete(obj)
            obj.close();
        end

        function close(obj)
            obj.closeFigures();
        end

        function setRig(obj, rig)
            obj.rig = rig;
            obj.didSetRig();
        end

        function didSetRig(obj)
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
            obj.didSetPersistor();
        end

        function didSetPersistor(obj) %#ok<MANU>

        end
        
        function p = createPreset(obj, name)
            p = symphonyui.core.ProtocolPreset(name, class(obj), obj.getProperties());
        end
        
        function m = getProperties(obj)
            m = obj.getPropertyDescriptors().toMap();
        end
        
        function setProperties(obj, map)
            names = map.keys;
            for i = 1:numel(names)
                obj.setProperty(names{i}, map(names{i}));
            end
        end
        
        function v = getProperty(obj, name)
            descriptor = obj.getPropertyDescriptor(name);
            v = descriptor.value;
        end
        
        function setProperty(obj, name, value)
            mpo = findprop(obj, name);
            if isempty(mpo) || ~strcmp(mpo.SetAccess, 'public')
                error([name ' is not a property with public set access']);
            end
            descriptor = obj.getPropertyDescriptor(name);
            if ~descriptor.type.canAccept(value)
                error([value ' does not conform to property type restrictions for ' name]);
            end
            obj.(name) = value;
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
            obj.numIntervalsPrepared = 0;
            obj.numIntervalsCompleted = 0;

            obj.rig.sampleRate = obj.sampleRate;
        end

        function prepareEpoch(obj, epoch) %#ok<INUSD>
            obj.numEpochsPrepared = obj.numEpochsPrepared + 1;
        end

        function prepareInterval(obj, interval) %#ok<INUSD>
            obj.numIntervalsPrepared = obj.numIntervalsPrepared + 1;
        end

        function controllerDidStartHardware(obj) %#ok<MANU>

        end

        function tf = shouldContinuePreloadingEpochs(obj)
            tf = obj.shouldContinuePreparingEpochs();
        end

        function tf = shouldWaitToContinuePreparingEpochs(obj) %#ok<MANU>
            tf = false;
        end

        function tf = shouldContinuePreparingEpochs(obj) %#ok<MANU>
            tf = false;
        end

        function tf = shouldContinueRun(obj) %#ok<MANU>
            tf = false;
        end

        function completeEpoch(obj, epoch)
            obj.numEpochsCompleted = obj.numEpochsCompleted + 1;
            obj.figureHandlerManager.updateFigures(epoch);
        end

        function completeInterval(obj, interval) %#ok<INUSD>
            obj.numIntervalsCompleted = obj.numIntervalsCompleted + 1;
        end

        function completeRun(obj) %#ok<MANU>

        end

        function h = showFigure(obj, className, varargin)
            h = obj.figureHandlerManager.showFigure(className, varargin{:});
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

        function [value, type] = createDeviceNamesProperty(obj, expression)
            names = obj.rig.getDeviceNames(expression);
            if isempty(names)
                names = {'(None)'};
            end
            value = names{1};
            type = symphonyui.core.PropertyType('char', 'row', names);
        end

    end

end
