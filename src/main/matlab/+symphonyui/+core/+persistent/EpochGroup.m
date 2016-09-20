classdef EpochGroup < symphonyui.core.persistent.TimelineEntity

    properties
        label
        source
    end

    properties (SetAccess = private)
        parent
        experiment
    end

    methods

        function obj = EpochGroup(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
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
            s = symphonyui.core.persistent.Source(obj.cobj.Source);
        end

        function set.source(obj, s)
            obj.cobj.Source = s.cobj;
        end

        function g = getEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.EpochGroups, @symphonyui.core.persistent.EpochGroup);
        end

        function g = getAllEpochGroups(obj)
            g = obj.cellArrayFromEnumerable(obj.cobj.AllEpochGroups, @symphonyui.core.persistent.EpochGroup);
        end

        function b = getEpochBlocks(obj)
            b = obj.cellArrayFromEnumerable(obj.cobj.EpochBlocks, @symphonyui.core.persistent.EpochBlock);
        end

        function g = get.parent(obj)
            cgrp = obj.cobj.Parent;
            if isempty(cgrp)
                g = [];
            else
                g = symphonyui.core.persistent.EpochGroup(cgrp);
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
            e = symphonyui.core.persistent.Experiment(obj.cobj.Experiment);
        end

        function t = getEntityType(obj) %#ok<MANU>
            t = symphonyui.core.persistent.EntityType.EPOCH_GROUP;
        end

    end

    methods (Static)

        function e = newEpochGroup(cobj, description)
            symphonyui.core.persistent.TimelineEntity.newTimelineEntity(cobj, description);
            e = symphonyui.core.persistent.EpochGroup(cobj);
        end

    end

end
