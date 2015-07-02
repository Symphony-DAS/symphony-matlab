classdef TimelineEntity < symphonyui.core.persistent.Entity
    
    properties (SetAccess = private)
        startTime
        endTime
    end
    
    methods
        
        function obj = TimelineEntity(cobj)
            obj@symphonyui.core.persistent.Entity(cobj);
        end
        
        function t = get.startTime(obj)
            t = obj.datetimeFromDateTimeOffset(obj.cobj.StartTime);
        end
        
        function t = get.endTime(obj)
            cendTime = obj.cobj.EndTime;
            if cendTime.HasValue
                t = obj.datetimeFromDateTimeOffset(cendTime.Value);
            else
                t = [];
            end
        end
        
    end
    
end

