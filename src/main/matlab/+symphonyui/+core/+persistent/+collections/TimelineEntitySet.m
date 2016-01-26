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
            t = [];
            if ~isempty(obj.objects) && all(cellfun(@(s)isequal(s.startTime, obj.objects{1}.startTime), obj.objects))
                t = obj.objects{1}.startTime;
            end
        end
        
        function t = get.endTime(obj)
            t = [];
            if ~isempty(obj.objects) && all(cellfun(@(s)isequal(s.endTime, obj.objects{1}.endTime), obj.objects))
                t = obj.objects{1}.endTime;
            end
        end
        
    end
    
end

