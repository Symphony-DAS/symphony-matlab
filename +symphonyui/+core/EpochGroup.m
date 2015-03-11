classdef EpochGroup < handle
    
    properties
        label
        id
        source
        keywords
        attributes
        
        parent
        children
    end
    
    methods
        
        function obj = EpochGroup(parent, label)
            obj.parent = parent;
            obj.label = label;
            obj.id = char(java.util.UUID.randomUUID);
        end
        
    end
    
end

