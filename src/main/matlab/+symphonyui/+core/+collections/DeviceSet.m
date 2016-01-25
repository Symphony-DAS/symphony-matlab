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
            n = strjoin(unique(cellfun(@(d)d.name, obj.objects, 'UniformOutput', false)), ', ');
        end
        
        function m = get.manufacturer(obj)
            m = strjoin(unique(cellfun(@(d)d.manufacturer, obj.objects, 'UniformOutput', false)), ', ');
        end
        
        function m = get.configuration(obj)
            maps = cell(1, numel(obj.objects));
            for i = 1:numel(obj.objects)
                maps{i} = obj.objects{i}.configuration;
            end
            m = obj.intersectMaps(maps);
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
            d = symphonyui.core.PropertyDescriptor.empty();
            if isempty(obj.objects)
                return;
            end
            
            d = obj.objects{1}.getConfigurationDescriptors();
            for i = 2:numel(obj.objects)
                keep = false(1, numel(d));
                for j = 1:numel(d)
                    if any(arrayfun(@(c)isequal(c,d(j)), obj.objects{i}.getConfigurationDescriptors()))
                        keep(j) = true;
                    end
                end
                d = d(keep);
            end
        end
        
        function s = get.inputStreams(obj)
            if isempty(obj.objects)
                s = {};
                return;
            end
            
            s = obj.objects{1}.inputStreams;
            for i = 2:numel(obj.objects)
                keep = false(1, numel(s));
                for j = 1:numel(s)
                    if any(cellfun(@(c)isequal(c,s{j}), obj.objects{i}.inputStreams))
                        keep(j) = true;
                    end
                end
                s = s(keep);
            end
        end
        
        function s = get.outputStreams(obj)
            if isempty(obj.objects)
                s = {};
                return;
            end
            
            s = obj.objects{1}.outputStreams;
            for i = 2:numel(obj.objects)
                keep = false(1, numel(s));
                for j = 1:numel(s)
                    if any(cellfun(@(c)isequal(c,s{j}), obj.objects{i}.outputStreams))
                        keep(j) = true;
                    end
                end
                s = s(keep);
            end
        end
        
        function b = get.background(obj)
            b = [];
            if isempty(obj.objects)
                return;
            end
        end
        
        function set.background(obj, b)
            for i = 1:obj.size
                obj.get(i).background = b;
            end
        end
        
        function applyBackground(obj)
            for i = 1:obj.size
                obj.get(i).applyBackground();
            end
        end
        
    end
    
end

