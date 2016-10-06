classdef IoBaseSet < symphonyui.core.persistent.collections.TimelineEntitySet
    
    methods
        
        function obj = IoBaseSet(signals)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(signals);
        end
        
        function m = getDeviceConfigurationMap(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = obj.objects{1}.getDeviceConfigurationMap();
            for i = 2:numel(obj.objects)
                m = appbox.intersectMaps(m, obj.objects{i}.getDeviceConfigurationMap());
            end
        end
        
    end
    
end

