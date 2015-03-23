classdef Source < handle
    
    properties
        id
        label
        parent
        children
    end
    
    methods
        
        function obj = Source(label, parent)
            obj.id = char(java.util.UUID.randomUUID);
            obj.label = label;
            obj.parent = parent;
            obj.children = symphonyui.core.Source.empty(0, 1);
        end
        
        function addChild(obj, source)
            obj.children(end + 1) = source;
        end
        
    end
    
end

