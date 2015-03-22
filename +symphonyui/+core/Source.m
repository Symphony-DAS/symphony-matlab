classdef Source < handle
    
    properties
        id
        label
        parent
        children
    end
    
    methods
        
        function obj = Source(parent, label)
            obj.id = char(java.util.UUID.randomUUID);
            obj.parent = parent;
            obj.label = label;
        end
        
    end
    
end

