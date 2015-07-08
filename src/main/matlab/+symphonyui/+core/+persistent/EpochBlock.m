classdef EpochBlock < symphonyui.core.persistent.TimelineEntity

    properties (SetAccess = private)
        protocolId
        epochs
        epochGroup
    end

    methods

        function obj = EpochBlock(cobj, entityFactory)
            obj@symphonyui.core.persistent.TimelineEntity(cobj, entityFactory);
        end

        function p = get.protocolId(obj)
            p = char(obj.cobj.ProtocolID);
        end

        function e = get.epochs(obj)
            e = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.Epochs);
        end

        function g = get.epochGroup(obj)
            g = obj.entityFactory.fromCoreEntity(obj.cobj.EpochGroup);
        end

    end

end
