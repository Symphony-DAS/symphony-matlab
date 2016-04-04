classdef EpochGroup < symphonyui.core.persistent.TimelineEntity

    properties
        label
    end

    properties (SetAccess = private)
        source
        epochGroups
        allEpochGroups
        epochBlocks
        parent
        experiment
    end

    methods

        function obj = EpochGroup(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end
        
        function p = createPreset(obj, name)
            p = symphonyui.core.persistent.EpochGroupPreset(name,  obj.getDescriptionType(), obj.getProperties(), obj.label);
        end
        
        function applyPreset(obj, preset)
            applyPreset@symphonyui.core.persistent.TimelineEntity(obj, preset);
            obj.label = preset.label;
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

        function g = get.epochGroups(obj)
            g = obj.cellArrayFromEnumerableOrderedBy(obj.cobj.EpochGroups, 'startTime', @symphonyui.core.persistent.EpochGroup);
        end

        function g = get.allEpochGroups(obj)
            g = obj.cellArrayFromEnumerableOrderedBy(obj.cobj.AllEpochGroups, 'startTime', @symphonyui.core.persistent.EpochGroup);
        end

        function b = get.epochBlocks(obj)
            b = obj.cellArrayFromEnumerableOrderedBy(obj.cobj.EpochBlocks, 'startTime', @symphonyui.core.persistent.EpochBlock);
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

    end

    methods (Static)

        function e = newEpochGroup(cobj, description)
            symphonyui.core.persistent.TimelineEntity.newTimelineEntity(cobj, description);
            e = symphonyui.core.persistent.EpochGroup(cobj);
        end

    end

end
