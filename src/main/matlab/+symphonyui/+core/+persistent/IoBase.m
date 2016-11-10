classdef IoBase < symphonyui.core.persistent.Entity

    properties (SetAccess = private)
        device
        epoch
    end

    methods

        function obj = IoBase(cobj, factory)
            obj@symphonyui.core.persistent.Entity(cobj, factory);
        end

        function d = get.device(obj)
            d = obj.entityFactory.create(obj.cobj.Device);
        end
        
        function b = get.epoch(obj)
            b = obj.entityFactory.create(obj.cobj.Epoch);
        end
        
        function m = getConfigurationSettingMap(obj)
            dev = obj.device;
            m = containers.Map();
            spans = obj.cellArrayFromEnumerable(obj.cobj.ConfigurationSpans);
            for i = 1:numel(spans)
                nodes = obj.cellArrayFromEnumerable(spans{i}.Nodes);
                for k = 1:numel(nodes)
                    if strcmp(char(nodes{k}.Name), dev.name)
                        m = obj.mapFromKeyValueEnumerable(nodes{k}.Configuration, @obj.valueFromPropertyValue);
                        break;
                    end
                end
            end
        end
        
        function setConfigurationSetting(obj, name, value)
            descriptors = obj.getConfigurationSettingDescriptors();
            d = descriptors.findByName(name);
            if isempty(d)
                error([name ' does not exist']);
            end
            if d.isReadOnly
                error([name ' is read only']);
            end
            d.value = value;
            obj.tryCore(@()obj.cobj.SetConfigurationSetting(name, obj.propertyValueFromValue(value)));
        end
        
        function d = getConfigurationSettingDescriptors(obj)
            d = symphonyui.core.PropertyDescriptor.empty(0, 1);
            
            dev = obj.device;
            if any(strcmp(dev.getResourceNames(), symphonyui.core.Device.CONFIGURATION_SETTING_DESCRIPTORS_RESOURCE_NAME))
                dd = dev.getResource(symphonyui.core.Device.CONFIGURATION_SETTING_DESCRIPTORS_RESOURCE_NAME);
            else
                dd = symphonyui.core.PropertyDescriptor.empty(0, 1);
            end
            
            m = obj.getConfigurationSettingMap();
            keys = m.keys;
            for i = 1:numel(keys)
                k = keys{i};
                kd = dd.findByName(k);
                if isempty(kd)
                    kd = symphonyui.core.PropertyDescriptor(k, m(k));
                else
                    try
                        kd.value = m(k);
                    catch
                        kd = symphonyui.core.PropertyDescriptor(k, m(k));
                    end
                end
                d(end + 1) = kd; %#ok<AGROW>
            end
        end

    end

end
