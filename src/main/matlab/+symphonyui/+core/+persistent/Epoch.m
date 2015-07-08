classdef Epoch < symphonyui.core.persistent.TimelineEntity

    properties (SetAccess = private)
        protocolParameters
        responses
        stimuli
        backgrounds
        epochBlock
    end

    methods

        function obj = Epoch(cobj, entityFactory)
            obj@symphonyui.core.persistent.TimelineEntity(cobj, entityFactory);
        end

        function p = get.protocolParameters(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.ProtocolParameters);
        end

        function r = get.responses(obj)
            r = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.Responses);
        end

        function s = get.stimuli(obj)
            s = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.Stimuli);
        end

        function b = get.backgrounds(obj)
            b = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.Backgrounds);
        end

        function b = get.epochBlock(obj)
            b = obj.entityFactory.fromCoreEntity(obj.cobj.EpochBlock);
        end

    end

end
