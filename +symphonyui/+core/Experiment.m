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
        epochGroups
        currentEpochGroup
        notes
    end
    
    methods
        
        function obj = Experiment(name, location)
            obj.name = name;
            obj.location = location;
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
            obj.currentEpochGroup = symphonyui.core.EpochGroup(obj.currentEpochGroup, label);
            notify(obj, 'BeganEpochGroup');
        end
        
        function endEpochGroup(obj)
            disp(['End Epoch Group: ' obj.currentEpochGroup.label]);
            obj.currentEpochGroup = obj.currentEpochGroup.parent;
            notify(obj, 'EndedEpochGroup');
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

