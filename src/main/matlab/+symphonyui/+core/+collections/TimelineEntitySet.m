classdef TimelineEntitySet < symphonyui.core.collections.EntitySet
    
    properties
        startTime
        endTime
    end
    
    methods
        
        function obj = TimelineEntitySet(entities)
            obj@symphonyui.core.collections.EntitySet(entities);
        end
        
        function t = get.startTime(obj)
            times = cellfun(@(e)e.startTime, obj.entities, 'UniformOutput', false);
            if isempty(times)
                t = [];
                return;
            end
            times = sort([times{:}]);
            t = times(1);
        end
        
        function t = get.endTime(obj)
            times = cellfun(@(e)e.endTime, obj.entities, 'UniformOutput', false);
            if isempty(times) || any(cellfun(@isempty, times))
                t = [];
                return;
            end
            times = sort([times{:}]);
            t = times(end);
        end
        
    end
    
end

