classdef Experiment < symphonyui.core.persistent.TimelineEntity

    properties
        purpose
    end

    methods

        function obj = Experiment(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end

        function p = createPreset(obj, name)
            p = createPreset@symphonyui.core.persistent.TimelineEntity(obj, name);
            p.classProperties('purpose') = obj.purpose;
        end

        function applyPreset(obj, preset)
            applyPreset@symphonyui.core.persistent.TimelineEntity(obj, preset);
            obj.purpose = preset.classProperties('purpose');
        end

        function p = get.purpose(obj)
            p = char(obj.cobj.Purpose);
        end

        function set.purpose(obj, p)
            obj.cobj.Purpose = p;
        end

        function d = getDevices(obj)
            d = obj.cellArrayFromEnumerable(obj.cobj.Devices, @symphonyui.core.persistent.Device);
        end

        function s = getSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Sources, @symphonyui.core.persistent.Source);
        end

        function s = getAllSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.AllSources, @symphonyui.core.persistent.Source);
        end

        function g = getEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups, @symphonyui.core.persistent.EpochGroup);
        end

        function g = getAllEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.AllEpochGroups, @symphonyui.core.persistent.EpochGroup);
        end

        function t = getEntityType(obj) %#ok<MANU>
            t = symphonyui.core.persistent.EntityType.EXPERIMENT;
        end

    end

    methods (Static)

        function e = newExperiment(cobj, description)
            symphonyui.core.persistent.TimelineEntity.newTimelineEntity(cobj, description);
            e = symphonyui.core.persistent.Experiment(cobj);
        end

    end

end
