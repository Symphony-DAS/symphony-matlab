classdef Experiment < handle
    
    events
        Opened
        Closed
        AddedSource
        BeganEpochGroup
        EndedEpochGroup
        RecordedEpoch
        AddedNote
    end
    
    properties (SetAccess = private)
        id
        name
        location
        purpose
        startTime
        endTime
        sources
        epochGroups
        currentEpochGroup
        notes
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
            obj.id = fullfile(obj.location, obj.name);
            obj.sources = Source.empty(0, 1);
            obj.epochGroups = EpochGroup.empty(0, 1);
            obj.notes = Note.empty(0, 1);
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
            list = createFlatList(obj.sources, symphonyui.core.Source.empty(0, 1));
            for k = 1:numel(list)
                i{k} = list(k).id; %#ok<AGROW>
            end
        end
        
        function s = getSource(obj, id)
            list = createFlatList(obj.sources, symphonyui.core.Source.empty(0, 1));
            s = list(arrayfun(@(e)strcmp(e.id, id), list));
        end
        
        function addSource(obj, label, parentId)
            if isempty(label)
                error('Label cannot be empty');
            end
            sourceId = obj.idGenerators.source.generateId(label);
            parent = obj.getSource(parentId);
            source = symphonyui.core.Source(sourceId, label, parent);
            if isempty(parent)
                obj.sources(end + 1) = source;
            else
                parent.addChild(source);
            end
            notify(obj, 'AddedSource', symphonyui.core.SourceEventData(source));
        end
        
        function i = getAllEpochGroupIds(obj)
            i = {};
            list = createFlatList(obj.epochGroups, symphonyui.core.EpochGroup.empty(0, 1));
            for k = 1:numel(list)
                i{k} = list(k).id; %#ok<AGROW>
            end
        end
        
        function e = getEpochGroup(obj, id)
            list = createFlatList(obj.epochGroups, symphonyui.core.EpochGroup.empty(0, 1));
            e = list(arrayfun(@(e)strcmp(e.id, id), list));
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
                obj.epochGroups(end + 1) = group;
            else
                parent.addChild(group);
            end
            obj.currentEpochGroup = group;
            group.start();
            notify(obj, 'BeganEpochGroup', symphonyui.core.EpochGroupEventData(group));
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
            notify(obj, 'EndedEpochGroup', symphonyui.core.EpochGroupEventData(group));
        end
        
        function addNote(obj, text)
            obj.notes(end + 1) = symphonyui.core.Note(text, now);
            notify(obj, 'AddedNote');
        end
        
    end
    
end

function list = createFlatList(items, list)
    for i = 1:numel(items)
        list(end + 1) = items(i); %#ok<AGROW>

        children = items(i).children;
        list = createFlatList(children, list);
    end
end


