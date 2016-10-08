classdef IoBaseSet < symphonyui.core.persistent.collections.TimelineEntitySet

    methods

        function obj = IoBaseSet(signals)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(signals);
        end

        function m = getConfigurationSettingMap(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = obj.objects{1}.getConfigurationSettingMap();
            for i = 2:numel(obj.objects)
                m = appbox.intersectMaps(m, obj.objects{i}.getConfigurationSettingMap());
            end
        end
        
        function setConfigurationSetting(obj, key, value)
            for i = 1:numel(obj.objects)
                obj.objects{i}.setConfigurationSetting(key, value);
            end
        end
        
        function d = getConfigurationSettingDescriptors(obj)
            if isempty(obj.objects)
                d = symphonyui.core.PropertyDescriptor.empty();
                return;
            end
            d = obj.objects{1}.getConfigurationSettingDescriptors();
            for i = 2:numel(obj.objects)
                d = appbox.intersect(d, obj.objects{i}.getConfigurationSettingDescriptors());
            end
        end

    end

end
