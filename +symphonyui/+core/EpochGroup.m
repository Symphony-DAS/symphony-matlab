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
            if ~isempty(parent)
                parent.addChild(obj);
            end
            obj.label = label;
            obj.id = char(java.util.UUID.randomUUID);
            obj.children = symphonyui.core.EpochGroup.empty(0, 1);
        end
        
        function addChild(obj, group)
            obj.children(end + 1) = group;
        end
        
    end
    
end

