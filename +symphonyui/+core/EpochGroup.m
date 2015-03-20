classdef EpochGroup < handle
    
    properties
        id
        label
        source
        keywords
        attributes
        
        parent
        children
    end
    
    methods
        
        function obj = EpochGroup(parent, label)
            obj.id = char(java.util.UUID.randomUUID);
            obj.parent = parent;
            obj.label = label;
            obj.children = symphonyui.core.EpochGroup.empty(0, 1);
        end
        
        function addChild(obj, group)
            obj.children(end + 1) = group;
        end
        
    end
    
end

