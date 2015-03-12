classdef Experiment < handle
    
    events
        Opened
        Closed
        BeganEpochGroup
        EndedEpochGroup
        AddedNote
    end
    
    properties
        name
        location
        id
        epochGroups
        currentEpochGroup
        notes
    end
    
    methods
        
        function obj = Experiment(name, location)
            obj.name = name;
            obj.location = location;
            obj.id = char(java.util.UUID.randomUUID);
            obj.epochGroups = symphonyui.core.EpochGroup.empty(0, 1);
            obj.notes = symphonyui.core.Note.empty(0, 1);
        end
        
        function open(obj)
            notify(obj, 'Opened');
        end
        
        function close(obj)
            notify(obj, 'Closed');
        end
        
        function beginEpochGroup(obj, label)
            disp(['Begin Epoch Group: ' label]);
            group = symphonyui.core.EpochGroup(obj.currentEpochGroup, label);
            if isempty(obj.currentEpochGroup)
                obj.epochGroups(end + 1) = group;
            end
            obj.currentEpochGroup = group;
            notify(obj, 'BeganEpochGroup', symphonyui.core.EpochGroupEventData(group));
        end
        
        function endEpochGroup(obj)
            disp(['End Epoch Group: ' obj.currentEpochGroup.label]);
            group = obj.currentEpochGroup;
            obj.currentEpochGroup = group.parent;
            notify(obj, 'EndedEpochGroup', symphonyui.core.EpochGroupEventData(group));
        end
        
        function tf = hasCurrentEpochGroup(obj)
            tf = ~isempty(obj.currentEpochGroup);
        end
        
        function addNote(obj, note)
            obj.notes(end + 1) = note;
            notify(obj, 'AddedNote');
        end
        
    end
    
end

