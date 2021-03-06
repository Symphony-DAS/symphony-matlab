classdef EpochBlock < symphonyui.core.persistent.TimelineEntity

    properties (SetAccess = private)
        protocolId
        protocolParameters
        epochGroup
    end

    methods

        function obj = EpochBlock(cobj, factory)
            obj@symphonyui.core.persistent.TimelineEntity(cobj, factory);
        end

        function p = get.protocolId(obj)
            p = char(obj.cobj.ProtocolID);
        end

        function p = get.protocolParameters(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.ProtocolParameters, @obj.valueFromPropertyValue);
        end

        function e = getEpochs(obj)
            e = obj.cellArrayFromEnumerable(obj.cobj.Epochs, @(ce)obj.entityFactory.create(ce));
        end

        function g = get.epochGroup(obj)
            g = obj.entityFactory.create(obj.cobj.EpochGroup);
        end

        function t = getEntityType(obj) %#ok<MANU>
            t = symphonyui.core.persistent.EntityType.EPOCH_BLOCK;
        end

    end

end
