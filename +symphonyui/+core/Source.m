classdef Source < symphonyui.core.Entity
    
    properties (Hidden)
        id
        label
        parent
        children
    end
    
    methods
        
        function obj = Source()
            obj.id = char(java.util.UUID.randomUUID);
%             obj.label = label;
%             obj.parent = parent;
            obj.children = symphonyui.core.Source.empty(0, 1);
        end
        
        function addChild(obj, source)
            obj.children(end + 1) = source;
        end
        
    end
    
end

