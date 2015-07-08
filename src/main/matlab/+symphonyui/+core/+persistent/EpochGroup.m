classdef EpochGroup < symphonyui.core.persistent.TimelineEntity

    properties (SetAccess = private)
        label
        source
        epochGroups
        epochBlocks
        parent
        experiment
    end

    methods

        function obj = EpochGroup(cobj, entityFactory)
            obj@symphonyui.core.persistent.TimelineEntity(cobj, entityFactory);
        end

        function p = get.label(obj)
            p = char(obj.cobj.Label);
        end

        function s = get.source(obj)
            s = obj.entityFactory.fromCoreEntity(obj.cobj.Source);
        end

        function g = get.epochGroups(obj)
            g = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.EpochGroups);
        end

        function b = get.epochBlocks(obj)
            b = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.EpochBlocks);
        end

        function g = get.parent(obj)
            cgrp = obj.cobj.Parent;
            if isempty(cgrp)
                g = [];
            else
                g = obj.entityFactory.fromCoreEntity(cgrp);
            end
        end

        function e = get.experiment(obj)
            e = obj.entityFactory.fromCoreEntity(obj.cobj.Experiment);
        end

    end

end
