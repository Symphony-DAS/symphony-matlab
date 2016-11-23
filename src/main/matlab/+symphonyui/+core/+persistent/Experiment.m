classdef Experiment < symphonyui.core.persistent.TimelineEntity

    properties (SetObservable)
        purpose
    end

    methods

        function obj = Experiment(cobj, factory)
            obj@symphonyui.core.persistent.TimelineEntity(cobj, factory);
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
            d = obj.cellArrayFromEnumerable(obj.cobj.Devices, @(ce)obj.entityFactory.create(ce));
        end

        function s = getSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Sources, @(ce)obj.entityFactory.create(ce));
        end

        function s = getAllSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.AllSources, @(ce)obj.entityFactory.create(ce));
        end

        function g = getEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups, @(ce)obj.entityFactory.create(ce));
        end

        function g = getAllEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.AllEpochGroups, @(ce)obj.entityFactory.create(ce));
        end

        function t = getEntityType(obj) %#ok<MANU>
            t = symphonyui.core.persistent.EntityType.EXPERIMENT;
        end

    end

    methods (Static)

        function e = newExperiment(cobj, factory, description)
            symphonyui.core.persistent.TimelineEntity.newTimelineEntity(cobj, factory, description);
            e = factory.create(cobj);
        end

    end

end
