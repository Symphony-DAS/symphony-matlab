classdef Epoch < symphonyui.core.persistent.TimelineEntity

    properties (SetAccess = private)
        protocolParameters
        epochBlock
    end

    methods

        function obj = Epoch(cobj, factory)
            obj@symphonyui.core.persistent.TimelineEntity(cobj, factory);
        end

        function p = get.protocolParameters(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.ProtocolParameters, @obj.valueFromPropertyValue);
        end

        function r = getResponses(obj)
            r = obj.cellArrayFromEnumerable(obj.cobj.Responses, @(ce)obj.entityFactory.create(ce));
        end

        function m = getResponseMap(obj)
            m = containers.Map();
            r = obj.getResponses();
            for i = 1:numel(r)
                m(r{i}.device.name) = r{i};
            end
        end

        function s = getStimuli(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Stimuli, @(ce)obj.entityFactory.create(ce));
        end

        function m = getStimulusMap(obj)
            m = containers.Map();
            s = obj.getStimuli();
            for i = 1:numel(s)
                m(s{i}.device.name) = s{i};
            end
        end

        function b = getBackgrounds(obj)
            b = obj.cellArrayFromEnumerable(obj.cobj.Backgrounds, @(ce)obj.entityFactory.create(ce));
        end
        
        function m = getBackgroundMap(obj)
            m = containers.Map();
            b = obj.getBackgrounds();
            for i = 1:numel(b)
                m(b{i}.device.name) = b{i};
            end
        end

        function b = get.epochBlock(obj)
            b = obj.entityFactory.create(obj.cobj.EpochBlock);
        end

        function t = getEntityType(obj) %#ok<MANU>
            t = symphonyui.core.persistent.EntityType.EPOCH;
        end

    end

end
