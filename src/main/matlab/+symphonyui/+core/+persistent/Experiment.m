classdef Experiment < symphonyui.core.persistent.TimelineEntity

    properties (SetAccess = private)
        purpose
        devices
        sources
        allSources
        epochGroups
    end

    methods

        function obj = Experiment(cobj, entityFactory)
            obj@symphonyui.core.persistent.TimelineEntity(cobj, entityFactory);
        end

        function p = get.purpose(obj)
            p = char(obj.cobj.Purpose);
        end

        function d = get.devices(obj)
            d = obj.entityFactory.fromCoreEntityEnumerable(obj.cobj.Devices);
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

    end

end
