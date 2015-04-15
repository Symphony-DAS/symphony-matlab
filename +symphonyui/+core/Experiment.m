classdef Experiment < symphonyui.core.Entity

    events
        Opened
        Closed
        AddedSource
        BeganEpochGroup
        EndedEpochGroup
        RecordedEpoch
    end

    properties (SetAccess = private)
        name
        location
        purpose
        startTime
        endTime
        sources
        epochGroups
        currentEpochGroup
    end

    properties (Access = private)
        idGenerators
    end

    methods

        function obj = Experiment(name, location, purpose)
            import symphonyui.core.*;

            obj.name = name;
            obj.location = location;
            obj.purpose = purpose;
            obj.sources = {};
            obj.epochGroups = {};
            obj.idGenerators = struct( ...
                'source', util.IdGenerator(), ...
                'epochGroup', util.IdGenerator());
        end

        function open(obj)
            obj.startTime = now;
            notify(obj, 'Opened');
        end

        function close(obj)
            obj.endTime = now;
            notify(obj, 'Closed');
        end

        function i = getAllSourceIds(obj)
            i = {};
            list = createFlatList(obj.sources);
            for k = 1:numel(list)
                i{k} = list{k}.id; %#ok<AGROW>
            end
        end

        function s = getSource(obj, id)
            list = createFlatList(obj.sources);
            index = cellfun(@(c)strcmp(c.id, id), list);
            if isempty(index)
                error(['No source with id ''' id '''']);
            end
            s = list{index};
        end

        function addSource(obj, label, parentId)
            if isempty(label)
                error('Label cannot be empty');
            end
            sourceId = obj.idGenerators.source.generateId(label);
            if isempty(parentId)
                parent = [];
            else
                parent = obj.getSource(parentId);
            end
            source = symphonyui.core.Source(sourceId, label, parent);
            if isempty(parent)
                obj.sources{end + 1} = source;
            else
                parent.addChild(source);
            end
            notify(obj, 'AddedSource', symphonyui.core.util.DomainEventData(source));
        end

        function i = getAllEpochGroupIds(obj)
            i = {};
            list = createFlatList(obj.epochGroups);
            for k = 1:numel(list)
                i{k} = list(k).id; %#ok<AGROW>
            end
        end

        function e = getEpochGroup(obj, id)
            list = createFlatList(obj.epochGroups);
            index = cellfun(@(c)strcmp(c.id, id), list);
            if isempty(index)
                error(['No epoch group with id ''' id '''']);
            end
            e = list{index};
        end

        function beginEpochGroup(obj, label, sourceId)
            if isempty(label)
                error('Label cannot be empty');
            end
            if isempty(sourceId)
                error('Source cannot be empty');
            end
            groupId = obj.idGenerators.epochGroup.generateId(label);
            source = obj.getSource(sourceId);
            parent = obj.currentEpochGroup;
            group = symphonyui.core.EpochGroup(groupId, label, source, parent);
            if isempty(parent)
                obj.epochGroups{end + 1} = group;
            else
                parent.addChild(group);
            end
            obj.currentEpochGroup = group;
            group.start();
            notify(obj, 'BeganEpochGroup', symphonyui.core.util.DomainEventData(group));
        end

        function endEpochGroup(obj)
            disp(['End Epoch Group: ' obj.currentEpochGroup.label]);
            group = obj.currentEpochGroup;
            group.stop();
            if group.parent == obj
                obj.currentEpochGroup = [];
            else
                obj.currentEpochGroup = group.parent;
            end
            notify(obj, 'EndedEpochGroup', symphonyui.core.util.DomainEventData(group));
        end

    end

end

function list = createFlatList(items, list)
    if nargin < 2
        list = {};
    end

    for i = 1:numel(items)
        list{end + 1} = items{i}; %#ok<AGROW>

        children = items{i}.children;
        list = createFlatList(children, list);
    end
end
