classdef EntitySet < handle
    
    properties (SetAccess = private)
        size
        propertyMap
        keywords
        notes
    end
    
    properties (Access = protected)
        entities
    end
    
    methods
        
        function obj = EntitySet(entities)
            if nargin < 1 || isempty(entities)
                entities = {};
            end
            if ~iscell(entities)
                entities = {entities};
            end
            obj.entities = entities;
        end
        
        function s = get.size(obj)
            s = numel(obj.entities);
        end
        
        function e = get(obj, index)
            e = obj.entities{index};
        end
        
        function p = get.propertyMap(obj)
            maps = cell(1, numel(obj.entities));
            for i = 1:numel(obj.entities)
                maps{i} = obj.entities{i}.propertyMap;
            end
            p = obj.intersectMaps(maps);
        end
        
        function addProperty(obj, key, value)
            for i = 1:numel(obj.entities)
                obj.entities{i}.addProperty(key, value);
            end
        end
        
        function tf = removeProperty(obj, key)
            tf = false;
            for i = 1:numel(obj.entities)
                removed = obj.entities{i}.removeProperty(key);
                tf = tf || removed;
            end
        end
        
        function p = getPropertyDescriptors(obj)
            p = symphonyui.core.PropertyDescriptor.empty();
            if isempty(obj.entities)
                return;
            end
            
            % TODO: Implement merging of property descriptors.
            p = obj.entities{1}.getPropertyDescriptors();
        end
        
        function k = get.keywords(obj)
            if isempty(obj.entities)
                k = {};
                return;
            end
            
            k = obj.entities{1}.keywords;
            for i = 2:numel(obj.entities)
                k = intersect(k, obj.entities{i}.keywords);
            end
        end
        
        function tf = addKeyword(obj, keyword)
            tf = false;
            for i = 1:numel(obj.entities)
                added = obj.entities{i}.addKeyword(keyword);
                tf = tf || added;
            end
        end
        
        function tf = removeKeyword(obj, keyword)
            tf = false;
            for i = 1:numel(obj.entities)
                removed = obj.entities{i}.removeKeyword(keyword);
                tf = tf || removed;
            end
        end
        
        function n = get.notes(obj)
            if isempty(obj.entities)
                n = {};
                return;
            end
            
            n = obj.entities{1}.notes;
            for i = 2:numel(obj.entities)
                keep = false(1, numel(n));
                for j = 1:numel(n)
                    if any(cellfun(@(c)isequal(c,n{j}), obj.entities{i}.notes))
                        keep(j) = true;
                    end
                end
                n = n(keep);
            end
        end
        
        function n = addNote(obj, text, time)
            n = [];
            for i = 1:numel(obj.entities)
                n = obj.entities{i}.addNote(text, time);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function m = intersectMaps(obj, maps)
            m = containers.Map();
            if isempty(maps)
                return;
            end
            
            keys = maps{1}.keys;
            for i = 2:numel(obj.entities)
                keys = intersect(keys, maps{i}.keys);
            end
            
            values = cell(1, numel(keys));
            for i = 1:numel(keys)
                k = keys{i};
                v = {};
                for j = 1:numel(obj.entities)
                    p = maps{j}(k);
                    if ~any(cellfun(@(c)isequal(c, p), v))
                        v{end + 1} = p; %#ok<AGROW>
                    end
                end
                if numel(v) == 1
                    values{i} = v{1};
                else
                    values{i} = v;
                end
            end
            
            if ~isempty(keys)
                m = containers.Map(keys, values);
            end
        end
        
    end
    
end

