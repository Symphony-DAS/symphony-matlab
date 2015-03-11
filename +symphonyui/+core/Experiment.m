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
        notes
    end
    
    methods
        
        function obj = Experiment(name, location)
            obj.name = name;
            obj.location = location;
            obj.notes = symphonyui.core.Note.empty(0, 1);
        end
        
        function open(obj)
            notify(obj, 'Opened');
        end
        
        function close(obj)
            notify(obj, 'Closed');
        end
        
        function tf = hasEpochGroup(obj)
            tf = ~isempty(obj.epochGroup);
        end
        
        function beginEpochGroup(obj, label, source, keywords, attributes)
            disp(['Begin Epoch Group: ' label]);
            obj.epochGroup = symphonyui.core.EpochGroup(label, source, keywords, attributes);
            notify(obj, 'BeganEpochGroup');
        end
        
        function endEpochGroup(obj)
            disp(['End Epoch Group: ' obj.epochGroup.label]);
            obj.epochGroup = obj.epochGroup.parent;
            notify(obj, 'EndedEpochGroup');
        end
        
        function addNote(obj, note)
            obj.notes(end + 1) = note;
            notify(obj, 'AddedNote');
        end
        
    end
    
end

