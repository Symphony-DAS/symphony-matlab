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
        
        function d = get.devices(obj)
            warning('The devices property is deprecated. Use getDevices().');
            d = obj.getDevices();
        end

        function d = getDevices(obj)
            d = obj.cellArrayFromEnumerable(obj.cobj.Devices, @symphonyui.core.persistent.Device);
        end
        
        function s = get.sources(obj)
            warning('The sources property is deprecated. Use getSources().');
            s = obj.getSources();
        end

        function s = getSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Sources, @symphonyui.core.persistent.Source);
        end
        
        function s = get.allSources(obj)
            warning('The allSources property is deprecated. Use getAllSources().');
            s = obj.getAllSources();
        end

        function s = getAllSources(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.AllSources, @symphonyui.core.persistent.Source);
        end
        
        function g = get.epochGroups(obj)
            warning('The epochGroups property is deprecated. Use getEpochGroups().');
            g = obj.getEpochGroups();
        end

        function g = getEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups, @symphonyui.core.persistent.EpochGroup);
        end
        
        function g = get.allEpochGroups(obj)
            warning('The allEpochGroups property is deprecated. Use getAllEpochGroups().');
            g = obj.getAllEpochGroups();
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
