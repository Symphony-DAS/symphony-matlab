classdef ExperimentSet < symphonyui.core.collections.TimelineEntitySet
    
    properties
        purpose
    end
    
    methods
        
        function obj = ExperimentSet(experiments)
            obj@symphonyui.core.collections.TimelineEntitySet(experiments);
        end
        
        function p = get.purpose(obj)
            p = strjoin(unique(cellfun(@(e)e.purpose, obj.entities, 'UniformOutput', false)), ', ');
        end
        
        function set.purpose(obj, p)
            for i = 1:obj.size
                obj.get(i).purpose = p;
            end
        end
        
    end
    
end

