classdef EntitySet < symphonyui.core.collections.ObjectSet
    
    properties (SetAccess = private)
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
        
        function addProperty(obj, key, value)
            for i = 1:numel(obj.objects)
                obj.objects{i}.addProperty(key, value);
            end
        end
        
        function setProperty(obj, key, value)
            for i = 1:numel(obj.objects)
                obj.objects{i}.setProperty(key, value);
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
            if isempty(obj.objects)
                d = symphonyui.core.PropertyDescriptor.empty();
                return;
            end
            d = obj.objects{1}.getPropertyDescriptors();
            for i = 2:numel(obj.objects)
                d = obj.intersect(d, obj.objects{i}.getPropertyDescriptors());
            end
        end
        
        function k = get.keywords(obj)
            if isempty(obj.objects)
                k = {};
                return;
            end
            k = obj.objects{1}.keywords;
            for i = 2:numel(obj.objects)
                k = obj.intersect(k, obj.objects{i}.keywords);
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
                n = obj.intersect(n, obj.objects{i}.notes);
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

