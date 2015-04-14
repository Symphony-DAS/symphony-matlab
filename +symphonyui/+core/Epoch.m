classdef Epoch < symphonyui.core.Entity
    
    properties
        id
        label
        stimuli
        responses
        epochGroup
    end
    
    methods
        
        function obj = Epoch(epochGroup, label)
            obj.id = char(java.util.UUID.randomUUID);
            obj.label = label;
        end
        
        function addKeyword(obj, keyword)
            
        end
        
        function addProperty(obj, name, value)
            
        end
        
        function addStimulus(obj)
            
        end
        
        function recordResponse(obj)
            
        end
        
    end
    
end

