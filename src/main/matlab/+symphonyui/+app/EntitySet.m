classdef EntitySet < handle
    
    events
        AddedProperty
        RemovedProperty
        AddedKeyword
        RemovedKeyword
        AddedNote
    end
    
    properties (SetAccess = private)
        entities
        commonPropertyMap
        commonKeywords
        commonNotes
    end
    
    methods
        
        function obj = EntitySet(entities)
            if ~iscell(entities)
                entities = {entities};
            end
            obj.entities = entities;
        end
        
        function p = get.commonPropertyMap(obj)
            if isempty(obj.entities)
                p = containers.Map();
                return;
            end
            
            keys = obj.entities{1}.propertyMap.keys;
            for i = 2:numel(obj.entities)
                keys = intersect(keys, obj.entities{i}.propertyMap.keys);
            end
            
            values = cell(1, numel(keys));
            for i = 1:numel(keys)
                k = keys{i};
                v = cell(1, numel(obj.entities));
                for j = 1:numel(obj.entities)
                    v{j} = obj.entities{j}.propertyMap(k);
                end
                values{i} = unique(v);
            end
            
            if isempty(keys)
                p = containers.Map();
            else
                p = containers.Map(keys, values);
            end
        end
        
        function addProperty(obj, key, value)
            for i = 1:numel(obj.entities)
                obj.entities{i}.addProperty(key, value);
            end
            p.key = key;
            p.value = value;
            notify(obj, 'AddedProperty', symphonyui.app.AppEventData(p));
        end
        
        function tf = removeProperty(obj, key)
            tf = false;
            for i = 1:numel(obj.entities)
                removed = obj.entities{i}.removeProperty(key);
                tf = tf || removed;
            end
            if tf
                notify(obj, 'RemovedProperty', symphonyui.app.AppEventData(key));
            end
        end
        
        function k = get.commonKeywords(obj)
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
            if tf
                notify(obj, 'AddedKeyword', symphonyui.app.AppEventData(keyword));
            end
        end
        
        function tf = removeKeyword(obj, keyword)
            tf = false;
            for i = 1:numel(obj.entities)
                removed = obj.entities{i}.removeKeyword(keyword);
                tf = tf || removed;
            end
            if tf
                notify(obj, 'RemovedKeyword', symphonyui.app.AppEventData(keyword));
            end
        end
        
        function n = get.commonNotes(obj)
            if isempty(obj.entities)
                n = {};
                return;
            end
            
            n = obj.entities{1}.notes;
            if numel(obj.entities) > 1
                % TODO: implement
                n = {};
            end
        end
        
        function n = addNote(obj, text, time)
            n = [];
            for i = 1:numel(obj.entities)
                n = obj.entities{i}.addNote(text, time);
            end
            notify(obj, 'AddedNote', symphonyui.app.AppEventData(n));
        end
        
    end
    
end

