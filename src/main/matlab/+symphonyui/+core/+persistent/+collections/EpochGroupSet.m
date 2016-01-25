classdef EpochGroupSet < symphonyui.core.persistent.collections.TimelineEntitySet
    
    properties
        label
    end
    
    properties (SetAccess = private)
        sources
    end
    
    methods
        
        function obj = EpochGroupSet(groups)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(groups);
        end
        
        function l = get.label(obj)
            l = strjoin(unique(cellfun(@(g)g.label, obj.objects, 'UniformOutput', false)), ', ');
        end
        
        function set.label(obj, l)
            for i = 1:obj.size
                obj.get(i).label = l;
            end
        end
        
        function s = get.sources(obj)
            s = cellfun(@(g)g.source, obj.objects, 'UniformOutput', false);
        end
        
    end
    
end

