classdef IoBaseSet < symphonyui.core.persistent.collections.TimelineEntitySet

    methods

        function obj = IoBaseSet(signals)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(signals);
        end

        function m = getConfigurationMap(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = obj.objects{1}.getConfigurationMap();
            for i = 2:numel(obj.objects)
                m = appbox.intersectMaps(m, obj.objects{i}.getConfigurationMap());
            end
        end

    end

end
