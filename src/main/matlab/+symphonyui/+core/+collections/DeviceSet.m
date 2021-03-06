classdef DeviceSet < symphonyui.core.collections.ObjectSet

    properties (SetAccess = private)
        name
        manufacturer
    end

    properties
        background
    end

    methods

        function obj = DeviceSet(devices)
            if nargin < 1 || isempty(devices)
                devices = {};
            end
            obj@symphonyui.core.collections.ObjectSet(devices);
        end

        function n = get.name(obj)
            n = '';
            if ~isempty(obj.objects) && all(cellfun(@(d)isequal(d.name, obj.objects{1}.name), obj.objects))
                n = obj.objects{1}.name;
            end
        end

        function m = get.manufacturer(obj)
            m = '';
            if ~isempty(obj.objects) && all(cellfun(@(d)isequal(d.manufacturer, obj.objects{1}.manufacturer), obj.objects))
                m = obj.objects{1}.manufacturer;
            end
        end

        function addConfigurationSetting(obj, key, value, varargin)
            for i = 1:numel(obj.objects)
                obj.objects{i}.addConfigurationSetting(key, value, varargin{:});
            end
        end

        function setConfigurationSetting(obj, key, value)
            for i = 1:numel(obj.objects)
                obj.objects{i}.setConfigurationSetting(key, value);
            end
        end

        function tf = removeConfigurationSetting(obj, key)
            tf = false;
            for i = 1:numel(obj.objects)
                removed = obj.objects{i}.removeConfigurationSetting(key);
                tf = tf || removed;
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

        function s = getInputStreams(obj)
            if isempty(obj.objects)
                s = {};
                return;
            end
            s = obj.objects{1}.getInputStreams();
            for i = 2:numel(obj.objects)
                s = appbox.intersect(s, obj.objects{i}.getInputStreams());
            end
        end

        function tf = allHaveBoundInputStreams(obj)
            tf = true;
            for i = 1:numel(obj.objects)
                if isempty(obj.objects{i}.getInputStreams())
                    tf = false;
                    return;
                end
            end
        end

        function s = getOutputStreams(obj)
            if isempty(obj.objects)
                s = {};
                return;
            end
            s = obj.objects{1}.getOutputStreams();
            for i = 2:numel(obj.objects)
                s = appbox.intersect(s, obj.objects{i}.getOutputStreams());
            end
        end

        function tf = allHaveBoundOutputStreams(obj)
            tf = true;
            for i = 1:numel(obj.objects)
                if isempty(obj.objects{i}.getOutputStreams())
                    tf = false;
                    return;
                end
            end
        end

        function b = get.background(obj)
            b = [];
            if ~isempty(obj.objects) && all(cellfun(@(d)isequal(d.background, obj.objects{1}.background), obj.objects))
                b = obj.objects{1}.background;
            end
        end

        function set.background(obj, b)
            for i = 1:obj.size
                obj.get(i).background = b;
            end
        end

        function u = getBackgroundDisplayUnits(obj)
            u = '';
            if ~isempty(obj.objects) && all(cellfun(@(d)isequal(d.background.displayUnits, obj.objects{1}.background.displayUnits), obj.objects))
                u = obj.objects{1}.background.displayUnits;
            end
        end

        function applyBackground(obj)
            for i = 1:obj.size
                obj.get(i).applyBackground();
            end
        end

    end

end
