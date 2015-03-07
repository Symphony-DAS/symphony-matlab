classdef Experiment < handle
    
    events
        Opened
        Closed
        AddedNote
        BeganEpochGroup
        EndedEpochGroup
    end
    
    properties
        path
        epochGroup
    end
    
    methods
        
        function obj = Experiment(path)
            obj.path = path;
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
            disp(['Add Note: ' note]);
            notify(obj, 'AddedNote');
        end
        
    end
    
end

