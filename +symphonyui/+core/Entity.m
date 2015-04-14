classdef Entity < handle
    
    events (NotifyAccess = private)
        AddedKeyword
        AddedNote
    end
    
    properties (SetAccess = private)
        attributes
        keywords
        notes
    end
    
    methods
        
        function obj = Entity()
            obj.attributes = containers.Map();
            obj.keywords = {};
            obj.notes = symphonyui.core.Note.empty(0, 1);
        end
        
        function addProperty(obj, key, value)
            obj.attributes(key) = value;
        end
        
        function addKeyword(obj, keyword)
            obj.keywords{end + 1} = keyword;
            notify(obj, 'AddedKeyword', symphonyui.core.util.DomainEventData(keyword));
        end
        
        function addNote(obj, text)
            note = symphonyui.core.Note(text, now);
            obj.notes(end + 1) = note;
            notify(obj, 'AddedNote', symphonyui.core.util.DomainEventData(note));
        end
        
    end
    
end

