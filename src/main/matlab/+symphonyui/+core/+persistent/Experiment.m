classdef Experiment < symphonyui.core.persistent.TimelineEntity

    properties
        purpose
    end

    properties (SetAccess = private)
        devices
        sources
        allSources
        epochGroups
        allEpochGroups
    end

    methods

        function obj = Experiment(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end

        function p = get.purpose(obj)
            p = char(obj.cobj.Purpose);
        end

        function set.purpose(obj, p)
            obj.cobj.Purpose = p;
        end

        function d = get.devices(obj)
            d = obj.cellArrayFromEnumerable(obj.cobj.Devices, @symphonyui.core.persistent.Device);
        end

        function s = get.sources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Sources, @symphonyui.core.persistent.Source);
        end

        function s = get.allSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.AllSources, @symphonyui.core.persistent.Source);
        end

        function g = get.epochGroups(obj)
            g = obj.cellArrayFromEnumerableOrderedBy(obj.cobj.EpochGroups, 'startTime', @symphonyui.core.persistent.EpochGroup);
        end

        function g = get.allEpochGroups(obj)
            g = obj.cellArrayFromEnumerableOrderedBy(obj.cobj.AllEpochGroups, 'startTime', @symphonyui.core.persistent.EpochGroup);
        end

    end

    methods (Static)

        function e = newExperiment(cobj, description)
            symphonyui.core.persistent.TimelineEntity.newTimelineEntity(cobj, description);
            e = symphonyui.core.persistent.Experiment(cobj);
        end

    end

end
