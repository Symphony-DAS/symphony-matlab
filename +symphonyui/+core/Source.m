classdef Source < handle
    
    properties (Hidden)
        id
        label
        parent
        children
    end
    
    methods
        
        function obj = Source(label, parent)
            obj.id = char(java.util.UUID.randomUUID);
            obj.label = label;
            obj.propertyMap = containers.Map();
            obj.parent = parent;
            obj.children = symphonyui.core.Source.empty(0, 1);
        end
        
        function addChild(obj, source)
            obj.children(end + 1) = source;
        end
        
        function putProperty(obj, name, value)
            obj.propertyMap(name) = value;
        end
        
        function removeProperty(obj, name)
            obj.propertyMap.remove(name);
        end
        
    end
    
end

