classdef ExperimentSet < symphonyui.core.persistent.collections.TimelineEntitySet
    
    properties
        purpose
    end
    
    methods
        
        function obj = ExperimentSet(experiments)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(experiments);
        end
        
        function p = get.purpose(obj)
            p = strjoin(unique(cellfun(@(e)e.purpose, obj.objects, 'UniformOutput', false)), ', ');
        end
        
        function set.purpose(obj, p)
            for i = 1:obj.size
                obj.get(i).purpose = p;
            end
        end
        
    end
    
end

