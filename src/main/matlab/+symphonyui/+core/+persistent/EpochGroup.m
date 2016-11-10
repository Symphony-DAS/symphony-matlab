classdef EpochGroup < symphonyui.core.persistent.TimelineEntity

    properties
        label
        source
    end

    properties (SetAccess = private)
        epochGroups
        allEpochGroups
        epochBlocks
        parent
        experiment
    end

    methods

        function obj = EpochGroup(cobj, factory)
            obj@symphonyui.core.persistent.TimelineEntity(cobj, factory);
        end

        function p = createPreset(obj, name)
            p = createPreset@symphonyui.core.persistent.TimelineEntity(obj, name);
            p.classProperties('label') = obj.label;
        end

        function applyPreset(obj, preset)
            applyPreset@symphonyui.core.persistent.TimelineEntity(obj, preset);
            obj.label = preset.classProperties('label');
        end

        function p = get.label(obj)
            p = char(obj.cobj.Label);
        end

        function set.label(obj, l)
            obj.cobj.Label = l;
        end

        function s = get.source(obj)
            s = obj.entityFactory.create(obj.cobj.Source);
        end

        function set.source(obj, s)
            obj.cobj.Source = s.cobj;
        end
        
        function g = get.epochGroups(obj)
            warning('The epochGroups property is deprecated. Use getEpochGroups().');
            g = obj.getEpochGroups();
        end

        function g = getEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups, @(ce)obj.entityFactory.create(ce));
        end
        
        function g = get.allEpochGroups(obj)
            warning('The allEpochGroups property is deprecated. Use getAllEpochGroups().');
            g = obj.getAllEpochGroups();
        end

        function g = getAllEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.AllEpochGroups, @(ce)obj.entityFactory.create(ce));
        end
        
        function b = get.epochBlocks(obj)
            warning('The epochBlocks property is deprecated. Use getEpochBlocks().');
            b = obj.getEpochBlocks();
        end

        function b = getEpochBlocks(obj)
            b = obj.cellArrayFromEnumerable(obj.cobj.EpochBlocks, @(ce)obj.entityFactory.create(ce));
        end

        function g = get.parent(obj)
            cgrp = obj.cobj.Parent;
            if isempty(cgrp)
                g = [];
            else
                g = obj.entityFactory.create(cgrp);
            end
        end

        function a = getAncestors(obj)
            a = {};
            current = obj.parent;
            while ~isempty(current)
                a{end + 1} = current; %#ok<AGROW>
                current = current.parent;
            end
        end

        function e = get.experiment(obj)
            e = obj.entityFactory.create(obj.cobj.Experiment);
        end

        function t = getEntityType(obj) %#ok<MANU>
            t = symphonyui.core.persistent.EntityType.EPOCH_GROUP;
        end

    end

    methods (Static)

        function e = newEpochGroup(cobj, factory, description)
            symphonyui.core.persistent.TimelineEntity.newTimelineEntity(cobj, factory, description);
            e = factory.create(cobj);
        end

    end

end
