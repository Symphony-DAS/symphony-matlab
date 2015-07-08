classdef Source < symphonyui.core.persistent.Entity

    properties (SetAccess = private)
        label
        sources
        allSources
        epochGroups
        allEpochGroups
        parent
        experiment
    end

    methods

        function obj = Source(cobj, entityFactory)
            obj@symphonyui.core.persistent.Entity(cobj, entityFactory);
        end

        function n = get.label(obj)
            n = char(obj.cobj.Label);
        end

        function s = get.sources(obj)
            s = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.Sources);
        end

        function s = get.allSources(obj)
            s = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.AllSources);
        end

        function g = get.epochGroups(obj)
            g = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.EpochGroups);
        end

        function g = get.allEpochGroups(obj)
            g = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.AllEpochGroups);
        end

        function s = get.parent(obj)
            csrc = obj.cobj.Parent;
            if isempty(csrc)
                s = [];
            else
                s = obj.entityFactory.fromCoreEntity(csrc);
            end
        end

        function e = get.experiment(obj)
            e = obj.entityFactory.fromCoreEntity(obj.cobj.Experiment);
        end

    end

end
