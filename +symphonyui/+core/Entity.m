classdef Entity < handle

    events (NotifyAccess = private)
        AddedProperty
        AddedKeyword
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

            obj.propertyMap(key) = value;
            property.key = key;
            property.value = value;
            notify(obj, 'AddedProperty', symphonyui.core.util.DomainEventData(property));
        end

        function addKeyword(obj, keyword)
            obj.keywords{end + 1} = keyword;
            notify(obj, 'AddedKeyword', symphonyui.core.util.DomainEventData(keyword));
        end

        function addNote(obj, text)
            note = symphonyui.core.Note(text, now);
            obj.notes{end + 1} = note;
            notify(obj, 'AddedNote', symphonyui.core.util.DomainEventData(note));
        end

    end

end
