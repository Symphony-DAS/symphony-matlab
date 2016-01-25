classdef TimelineEntitySet < symphonyui.core.persistent.collections.EntitySet
    
    properties
        startTime
        endTime
    end
    
    methods
        
        function obj = TimelineEntitySet(objects)
            obj@symphonyui.core.persistent.collections.EntitySet(objects);
        end
        
        function t = get.startTime(obj)
            times = cellfun(@(e)e.startTime, obj.objects, 'UniformOutput', false);
            if isempty(times)
                t = [];
                return;
            end
            times = sort([times{:}]);
            t = times(1);
        end
        
        function t = get.endTime(obj)
            times = cellfun(@(e)e.endTime, obj.objects, 'UniformOutput', false);
            if isempty(times) || any(cellfun(@isempty, times))
                t = [];
                return;
            end
            times = sort([times{:}]);
            t = times(end);
        end
        
    end
    
end

