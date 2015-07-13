classdef Entity < symphonyui.core.CoreObject
    
    events
        AddedProperty
        RemovedProperty
        AddedKeyword
        RemovedKeyword
        AddedNote
    end
    
    properties (SetAccess = private)
        uuid
        propertiesMap
        keywords
        notes
    end
    
    properties (Access = protected)
        entityFactory
    end
    
    methods
        
        function obj = Entity(cobj, entityFactory)
            obj@symphonyui.core.CoreObject(cobj);
            obj.entityFactory = entityFactory;
        end
        
        function i = get.uuid(obj)
            i = char(obj.cobj.UUID.ToString());
        end
        
        function p = get.propertiesMap(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.Properties);
        end
        
        function addProperty(obj, key, value)
            if isempty(key)
                error('Key cannot be empty');
            end
            if isempty(value)
                error('Value cannot be empty');
            end
            obj.cobj.AddProperty(key, value);
            p.key = key;
            p.value = value;
            notify(obj, 'AddedProperty', symphonyui.core.util.DomainEventData(p));
        end
        
        function tf = removeProperty(obj, key)
            tf = obj.cobj.RemoveProperty(key);
            if tf
                notify(obj, 'RemovedProperty', symphonyui.core.util.DomainEventData(key));
            end
        end
        
        function k = get.keywords(obj)
            k = obj.cellArrayFromEnumerable(obj.cobj.Keywords, @char);
        end
        
        function tf = addKeyword(obj, keyword)
            if isempty(keyword)
                error('Keyword cannot be empty');
            end
            tf = obj.cobj.AddKeyword(keyword);
            if tf
                notify(obj, 'AddedKeyword', symphonyui.core.util.DomainEventData(keyword));
            end
        end
        
        function tf = removeKeyword(obj, keyword)
            tf = obj.cobj.RemoveKeyword(keyword);
            if tf
                notify(obj, 'RemovedKeyword', symphonyui.core.util.DomainEventData(keyword));
            end
        end
        
        function n = get.notes(obj)
            n = obj.cellArrayFromEnumerable(obj.cobj.Notes, @symphonyui.core.persistent.Note);
        end
        
        function addNote(obj, text, time)
            if nargin < 3
                time = datetime('now', 'TimeZone', 'local');
            end
            dto = obj.dateTimeOffsetFromDatetime(time);
            cnote = obj.cobj.AddNote(dto, text);
            notify(obj, 'AddedNote', symphonyui.core.util.DomainEventData(symphonyui.core.persistent.Note(cnote)));
        end
        
    end
    
end