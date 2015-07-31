classdef SourceSet < symphonyui.core.collections.EntitySet
    
    properties
        label
    end
    
    methods
        
        function obj = SourceSet(sources)
            obj@symphonyui.core.collections.EntitySet(sources);
        end
        
        function l = get.label(obj)
            l = strjoin(unique(cellfun(@(s)s.label, obj.entities, 'UniformOutput', false)), ', ');
        end
        
        function set.label(obj, l)
            for i = 1:obj.size
                obj.get(i).label = l;
            end
        end
        
    end
    
end

