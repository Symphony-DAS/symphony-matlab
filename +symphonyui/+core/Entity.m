classdef Entity < handle

    events (NotifyAccess = private)
        AddedProperty
        RemovedProperty
        AddedKeyword
        RemovedKeyword
        AddedNote
    end

    properties (SetAccess = private)
        propertyMap
        keywords
        notes
    end

    methods

        function obj = Entity()
            obj.propertyMap = containers.Map();
            obj.keywords = {};
            obj.notes = {};
        end

        function addProperty(obj, key, value)
            if isempty(key)
                error('Key cannot be empty');
            end
            if obj.propertyMap.isKey(key)
                error(['Property with key ''' key ''' already exists']);
            end
            obj.propertyMap(key) = value;
            property.key = key;
            property.value = value;
            notify(obj, 'AddedProperty', symphonyui.core.util.DomainEventData(property));
        end
        
        function removeProperty(obj, key)
            if ~obj.propertyMap.isKey(key)
                error(['No property with key ''' key '''']);
            end
            property.key = key;
            property.value = obj.propertyMap(key);
            obj.propertyMap.remove(key);
            notify(obj, 'RemovedProperty', symphonyui.core.util.DomainEventData(property));
        end

        function addKeyword(obj, keyword)
            if isempty(keyword)
                error('Keyword cannot be empty');
            end
            if any(strcmp(keyword, obj.keywords))
                error(['Keyword ''' keyword ''' already exists']);
            end
            obj.keywords{end + 1} = keyword;
            notify(obj, 'AddedKeyword', symphonyui.core.util.DomainEventData(keyword));
        end
        
        function removeKeyword(obj, keyword)
            index = strcmp(keyword, obj.keywords);
            if ~any(index)
                error(['No keyword ''' keyword '''']);
            end
            obj.keywords = obj.keywords(~index);
            notify(obj, 'RemovedKeyword', symphonyui.core.util.DomainEventData(keyword));
        end

        function addNote(obj, text)
            if isempty(text)
                error('Note cannot be empty');
            end
            note = symphonyui.core.Note(text, now);
            obj.notes{end + 1} = note;
            notify(obj, 'AddedNote', symphonyui.core.util.DomainEventData(note));
        end

    end

end
