classdef Protocol < handle
    % A Protocol is an acquisition routine that defines a sequence of experimental trials, called epochs. Each epoch may
    % present a set of stimuli and record a set of responses from devices in the current rig. A protocol may also define 
    % online analysis to perform, typically through the use of FigureHandlers.
    %
    % To write a new protocol:
    %   1. Subclass Protocol
    %   2. Add properties to your subclass to define user-configurable values
    %   3. Override methods to define protocol behavior
    %
    % Protocol Methods:
    %   getPreview          - Override to return a ProtocolPreview implementation that manages a preview for this protocol
    %
    %   didSetRig           - Override to perform actions after this protocol's rig is set
    %   didSetPersistor     - Override to perform actions after this protocol's persistor is set
    %
    %   prepareRun          - Override to perform actions before the start of the first epoch
    %   prepareEpoch        - Override to perform actions before each epoch is added to the epoch queue
    %   prepareInterval     - Override to perform actions before each interval is added to the epoch queue
    %   completeEpoch       - Override to perform actions after each epoch is completed
    %   completeInterval    - Override to perform actions after each interval is completed
    %   completeRun         - Override to perform actions after the last epoch has completed
    %
    %   shouldContinuePreloadingEpochs      - Override to return true/false to indicate if this protocol should continue preloading epochs
    %   shouldWaitToContinuePreparingEpochs - Override to return true/false to indicate if this protocol should wait to continue preparing epochs
    %   shouldContinuePreparingEpochs       - Override to return true/false to indicate if this protocol should continue preparing epochs
    %   shouldContinueRun                   - Override to return true/false to indicate if this protocol should continue run
    %
    %   isValid             - Override to return true/false to indicate if this protocol is valid and should be able to run
    
    properties
        sampleRate  % Acquisition sample rate (Hz)
    end

    properties (Hidden)
        sampleRateType  % Property type of the sampleRate property
    end

    properties (Access = protected)
        numEpochsPrepared       % Number of epochs prepared by this protocol since prepareRun()
        numEpochsCompleted      % Number of epochs completed by this protocol since prepareRun()
        numIntervalsPrepared    % Number of intervals prepared by this protocol since prepareRun()
        numIntervalsCompleted   % Number of intervals completed by this protocol since prepareRun()
        figureHandlerManager    % Manages figures shown by this protocol
    end

    properties (Access = protected, Transient)
        rig         % Rig assigned to this protocol in setRig()
        persistor   % Persistor assigned to this protocol in setPersistor(), may be empty if there is no persistor
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
            % Override to perform actions after this protocol's rig is set, e.g. assign property values based on rig
            % devices
            
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
            % Override to perform actions after this protocol's persistor is set, e.g. assign property values based on
            % experiment entities. Note that persistor may be assigned as empty is there is no persistor.

        end

        function p = createPreset(obj, name)
            descriptors = obj.getPropertyDescriptors();
            i = arrayfun(@(d)d.isReadOnly, descriptors);
            descriptors(i) = [];
            p = symphonyui.core.ProtocolPreset(name, class(obj), descriptors.toMap());
        end

        function applyPreset(obj, preset)
            if ~isempty(preset.protocolId) && ~strcmp(preset.protocolId, class(obj))
                error('Protocol ID mismatch');
            end
            obj.setPropertyMap(preset.propertyMap);
        end

        function m = getPropertyMap(obj)
            m = obj.getPropertyDescriptors().toMap();
        end

        function setPropertyMap(obj, map)
            exception = [];
            names = map.keys;
            for i = 1:numel(names)
                try
                    obj.setProperty(names{i}, map(names{i}));
                catch x
                    if isempty(exception)
                        exception = MException('symphonyui:core:Protocol', 'Failed to set one or more property values');
                    end
                    exception.addCause(x);
                end
            end
            if ~isempty(exception)
                throw(exception);
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
            % Override to return a ProtocolPreview implementation that manages a preview for this protocol, e.g.
            % StimuliPreview
            
            p = [];
        end

        function prepareRun(obj)
            % Override to perform actions before the start of the first epoch, e.g. show figures, set device 
            % backgrounds, etc.
            
            obj.clearFigures();

            obj.numEpochsPrepared = 0;
            obj.numEpochsCompleted = 0;
            obj.numIntervalsPrepared = 0;
            obj.numIntervalsCompleted = 0;

            obj.rig.sampleRate = obj.sampleRate;
        end

        function prepareEpoch(obj, epoch) %#ok<INUSD>
            % Override to perform actions before each epoch is added to the epoch queue, e.g. add stimuli, responses,
            % parameters, etc.
            
            obj.numEpochsPrepared = obj.numEpochsPrepared + 1;
        end

        function prepareInterval(obj, interval) %#ok<INUSD>
            % Override to perform actions before each interval is added to the epoch queue. An interval is an epoch that
            % is not saved.
            
            obj.numIntervalsPrepared = obj.numIntervalsPrepared + 1;
        end

        function controllerDidStartHardware(obj) %#ok<MANU>
            % Override to perform actions after the DAQ controller actually starts the hardware, e.g. play a 
            % synchronized visual stimulus from a disparate system
             
        end

        function tf = shouldContinuePreloadingEpochs(obj)
            % Override to return true/false to indicate if this protocol should continue preloading epochs
            
            tf = obj.shouldContinuePreparingEpochs();
        end

        function tf = shouldWaitToContinuePreparingEpochs(obj) %#ok<MANU>
            % Override to return true/false to indicate if this protocol should wait to continue preparing epochs
            
            tf = false;
        end

        function tf = shouldContinuePreparingEpochs(obj) %#ok<MANU>
            % Override to return true/false to indicate if this protocol should continue preparing epochs
            
            tf = false;
        end

        function tf = shouldContinueRun(obj) %#ok<MANU>
            % Override to return true/false to indicate if this protocol should continue run
            
            tf = false;
        end

        function completeEpoch(obj, epoch)
            % Override to perform actions after each epoch is completed, e.g. perform post-analysis
            
            obj.numEpochsCompleted = obj.numEpochsCompleted + 1;
            obj.figureHandlerManager.updateFigures(epoch);
        end

        function completeInterval(obj, interval) %#ok<INUSD>
            % Override to perform actions after each interval is completed
            
            obj.numIntervalsCompleted = obj.numIntervalsCompleted + 1;
        end

        function completeRun(obj) %#ok<MANU>
            % Override to perform actions after the last epoch has completed
            
        end

        function h = showFigure(obj, className, varargin)
            % Shows a figure handler with the given class name and returns the handler. Additional arguments are passed 
            % to the handler's constructor.
            
            h = obj.figureHandlerManager.showFigure(className, varargin{:});
        end

        function clearFigures(obj)
            % Clears all figure handlers of this protocol
            
            obj.figureHandlerManager.clearFigures();
        end

        function closeFigures(obj)
            % Closes all figure handlers of this protocol
            
            obj.figureHandlerManager.closeFigures();
        end

        function [tf, msg] = isValid(obj) %#ok<MANU>
            % Override to return true/false to indicate if this protocol is valid and should be able to run
            
            tf = true;
            msg = [];
        end

    end

    methods (Access = protected)

        function [value, type] = createDeviceNamesProperty(obj, expression)
            % A convenience method for creating a property value/type combination that allows a device name to be
            % selected from a list of available devices in the rig with names matching the given expression
            
            names = obj.rig.getDeviceNames(expression);
            if isempty(names)
                names = {'(None)'};
            end
            value = names{1};
            type = symphonyui.core.PropertyType('char', 'row', names);
        end

    end

end
