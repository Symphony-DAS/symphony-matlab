classdef Experiment < handle
    
    events
        BeganEpochGroup
        EndedEpochGroup
    end
    
    properties
        path
        purpose
        source
        epochGroup
    end
    
    methods
        
        function obj = Experiment(path, purpose, source)
            obj.path = path;
            obj.purpose = purpose;
            obj.source = source;
        end
        
        function open(obj)
            
        end
        
        function close(obj)
            
        end
        
        function addNote(obj, note)
            disp(['Add Note: ' note]);
        end
        
        function tf = hasEpochGroup(obj)
            tf = ~isempty(obj.epochGroup);
        end
        
        function beginEpochGroup(obj, label, source, keywords, attributes)
            disp(['Begin Epoch Group: ' label]);
            obj.epochGroup = symphonyui.models.EpochGroup(label, source, keywords, attributes);
            notify(obj, 'BeganEpochGroup');
        end
        
        function endEpochGroup(obj)
            disp(['End Epoch Group: ' obj.epochGroup.label]);
            obj.epochGroup = obj.epochGroup.parent;
            notify(obj, 'EndedEpochGroup');
        end
        
    end
    
end

