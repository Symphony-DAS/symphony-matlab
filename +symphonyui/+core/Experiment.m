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
    
    properties
        id
        name
        location
        purpose
        startTime
        endTime
        epochGroups
        currentEpochGroup
        sources
        notes
    end
    
    methods
        
        function obj = Experiment(name, location, purpose)
            obj.id = char(java.util.UUID.randomUUID);
            obj.name = name;
            obj.location = location;
            obj.purpose = purpose;
            obj.epochGroups = symphonyui.core.EpochGroup.empty(0, 1);
            obj.sources = symphonyui.core.Source.empty(0, 1);
            obj.notes = symphonyui.core.Note.empty(0, 1);
        end
        
        function open(obj)
            obj.startTime = now;
            notify(obj, 'Opened');
        end
        
        function close(obj)
            obj.endTime = now;
            notify(obj, 'Closed');
        end
        
        function l = getFlatSourceList(obj)
            l = getFlatSourceListHelper(obj.sources, symphonyui.core.Source.empty(0, 1));
        end
        
        function s = getSource(obj, id)
            list = obj.getFlatSourceList();
            s = list(arrayfun(@(e)strcmp(e.id, id), list));
        end
        
        function addSource(obj, label, parentId)
            if nargin < 3
                parent = [];
            else
                parent = obj.getSource(parentId);
            end
            source = symphonyui.core.Source(label, parent);
            if isempty(parent)
                obj.sources(end + 1) = source;
            else
                parent.addChild(source);
            end
            notify(obj, 'AddedSource', symphonyui.core.SourceEventData(source));
        end
        
        function beginEpochGroup(obj, label, sourceId)
            if isempty(sourceId)
                error('Source cannot be empty');
            end
            
            disp(['Begin Epoch Group: ' label]);
            source = obj.getSource(sourceId);
            parent = obj.currentEpochGroup;
            group = symphonyui.core.EpochGroup(label, source, parent);
            if isempty(parent)
                obj.epochGroups(end + 1) = group;
            else
                parent.addChild(group);
            end
            obj.currentEpochGroup = group;
            group.start();
            notify(obj, 'BeganEpochGroup', symphonyui.core.EpochGroupEventData(group));
        end
        
        function tf = canEndEpochGroup(obj)
            tf = ~isempty(obj.currentEpochGroup);
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
        
        function tf = canRecordEpochs(obj)
            tf = ~isempty(obj.currentEpochGroup);
        end
        
    end
    
end

function list = getFlatSourceListHelper(sources, list)
    for i = 1:numel(sources)
        list(end + 1) = sources(i); %#ok<AGROW>

        children = sources(i).children;
        list = getFlatSourceListHelper(children, list);
    end
end


