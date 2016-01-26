classdef DeviceSet < symphonyui.core.collections.ObjectSet
    
    properties (SetAccess = private)
        name
        manufacturer
        configuration
        inputStreams
        outputStreams
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
        
        function m = get.configuration(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = obj.objects{1}.configuration;
            for i = 2:numel(obj.objects)
                m = obj.intersectMaps(m, obj.objects{i}.configuration);
            end
        end
        
        function addConfigurationSetting(obj, key, value)
            for i = 1:numel(obj.objects)
                obj.objects{i}.addConfigurationSetting(key, value);
            end
        end
        
        function tf = removeConfigurationSetting(obj, key)
            tf = false;
            for i = 1:numel(obj.objects)
                removed = obj.objects{i}.removeConfigurationSetting(key);
                tf = tf || removed;
            end
        end
        
        function d = getConfigurationDescriptors(obj)
            if isempty(obj.objects)
                d = symphonyui.core.PropertyDescriptor.empty();
                return;
            end
            d = obj.objects{1}.getConfigurationDescriptors();
            for i = 2:numel(obj.objects)
                d = obj.intersect(d, obj.objects{i}.getConfigurationDescriptors());
            end
        end
        
        function s = get.inputStreams(obj)
            if isempty(obj.objects)
                s = {};
                return;
            end
            s = obj.objects{1}.inputStreams;
            for i = 2:numel(obj.objects)
                s = obj.intersect(s, obj.objects{i}.inputStreams);
            end
        end
        
        function s = get.outputStreams(obj)
            if isempty(obj.objects)
                s = {};
                return;
            end
            s = obj.objects{1}.outputStreams;
            for i = 2:numel(obj.objects)
                s = obj.intersect(s, obj.objects{i}.outputStreams);
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

