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

        function p = createPreset(obj, name)
            p = symphonyui.core.persistent.EntityPreset(name, obj.getEntityType(), obj.getDescriptionType(), containers.Map(), obj.getPropertyMap());
        end

        function applyPreset(obj, preset)
            for i = 1:numel(obj.objects)
                obj.objects{i}.applyPreset(preset);
            end
        end

        function addProperty(obj, key, value, varargin)
            for i = 1:numel(obj.objects)
                obj.objects{i}.addProperty(key, value, varargin{:});
            end
        end

        function setPropertyMap(obj, map)
            for i = 1:numel(obj.objects)
                obj.objects{i}.setPropertyMap(map);
            end
        end

        function setProperty(obj, key, value)
            for i = 1:numel(obj.objects)
                obj.objects{i}.setProperty(key, value);
            end
        end

        function m = getPropertyMap(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = obj.objects{1}.getPropertyMap();
            for i = 2:numel(obj.objects)
                m = obj.intersectMaps(m, obj.objects{i}.getPropertyMap());
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
            warning('The notes property is deprecated. Use getNotes().');
            n = obj.getNotes();
        end

        function n = getNotes(obj)
            if isempty(obj.objects)
                n = {};
                return;
            end
            n = obj.objects{1}.getNotes();
            for i = 2:numel(obj.objects)
                n = obj.intersect(n, obj.objects{i}.getNotes());
            end
        end

        function n = addNote(obj, text, time)
            n = [];
            for i = 1:numel(obj.objects)
                n = obj.objects{i}.addNote(text, time);
            end
        end

        function t = getEntityType(obj)
            t = [];
            if ~isempty(obj.objects) && all(cellfun(@(e)isequal(e.getEntityType(), obj.objects{1}.getEntityType()), obj.objects))
                t = obj.objects{1}.getEntityType();
            end
        end

        function t = getDescriptionType(obj)
            t = [];
            if ~isempty(obj.objects) && all(cellfun(@(e)isequal(e.getDescriptionType(), obj.objects{1}.getDescriptionType()), obj.objects))
                t = obj.objects{1}.getDescriptionType();
            end
        end

    end

end
