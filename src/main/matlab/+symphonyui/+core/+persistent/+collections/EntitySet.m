classdef EntitySet < symphonyui.core.collections.ObjectSet
    
    properties (SetAccess = private)
        propertyMap
        keywords
        notes
    end
    
    methods
        
        function obj = EntitySet(entities)
            if nargin < 1 || isempty(entities)
                entities = {};
            end
            obj@symphonyui.core.collections.ObjectSet(entities);
        end
        
        function m = get.propertyMap(obj)
            maps = cell(1, numel(obj.objects));
            for i = 1:numel(obj.objects)
                maps{i} = obj.objects{i}.propertyMap;
            end
            m = obj.intersectMaps(maps);
        end
        
        function addProperty(obj, key, value)
            for i = 1:numel(obj.objects)
                obj.objects{i}.addProperty(key, value);
            end
        end
        
        function tf = removeProperty(obj, key)
            tf = false;
            for i = 1:numel(obj.objects)
                removed = obj.objects{i}.removeProperty(key);
                tf = tf || removed;
            end
        end
        
        function d = getPropertyDescriptors(obj)
            d = symphonyui.core.PropertyDescriptor.empty();
            if isempty(obj.objects)
                return;
            end
            
            d = obj.objects{1}.getPropertyDescriptors();
            for i = 2:numel(obj.objects)
                keep = false(1, numel(d));
                for j = 1:numel(d)
                    if any(arrayfun(@(c)isequal(c,d(j)), obj.objects{i}.getPropertyDescriptors()))
                        keep(j) = true;
                    end
                end
                d = d(keep);
            end
        end
        
        function k = get.keywords(obj)
            if isempty(obj.objects)
                k = {};
                return;
            end
            
            k = obj.objects{1}.keywords;
            for i = 2:numel(obj.objects)
                k = intersect(k, obj.objects{i}.keywords);
            end
        end
        
        function tf = addKeyword(obj, keyword)
            tf = false;
            for i = 1:numel(obj.objects)
                added = obj.objects{i}.addKeyword(keyword);
                tf = tf || added;
            end
        end
        
        function tf = removeKeyword(obj, keyword)
            tf = false;
            for i = 1:numel(obj.objects)
                removed = obj.objects{i}.removeKeyword(keyword);
                tf = tf || removed;
            end
        end
        
        function n = get.notes(obj)
            if isempty(obj.objects)
                n = {};
                return;
            end
            
            n = obj.objects{1}.notes;
            for i = 2:numel(obj.objects)
                keep = false(1, numel(n));
                for j = 1:numel(n)
                    if any(cellfun(@(c)isequal(c,n{j}), obj.objects{i}.notes))
                        keep(j) = true;
                    end
                end
                n = n(keep);
            end
        end
        
        function n = addNote(obj, text, time)
            n = [];
            for i = 1:numel(obj.objects)
                n = obj.objects{i}.addNote(text, time);
            end
        end
        
    end
    
end

