classdef EpochGroup < handle
    
    properties
        id
        label
        startTime
        endTime
        source
        keywords
        attributes
        epochs
        
        parent
        children
    end
    
    methods
        
        function obj = EpochGroup(label, source, parent)
            if nargin < 3
                parent = [];
            end
            obj.id = char(java.util.UUID.randomUUID);
            obj.parent = parent;
            obj.label = label;
            obj.source = source;
            obj.children = symphonyui.core.EpochGroup.empty(0, 1);
        end
        
        function start(obj)
            obj.startTime = now;
        end
        
        function stop(obj)
            obj.endTime = now;
        end
        
        function addChild(obj, group)
            obj.children(end + 1) = group;
        end
        
    end
    
end

