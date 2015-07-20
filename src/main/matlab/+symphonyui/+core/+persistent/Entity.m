classdef Entity < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        uuid
        propertyMap
        keywords
        notes
    end
    
    methods
        
        function obj = Entity(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function i = get.uuid(obj)
            i = char(obj.cobj.UUID.ToString());
        end
        
        function p = get.propertyMap(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.Properties);
        end
        
        function addProperty(obj, key, value)
            obj.tryCore(@()obj.cobj.AddProperty(key, value));
        end
        
        function tf = removeProperty(obj, key)
            tf = obj.tryCoreWithReturn(@()obj.cobj.RemoveProperty(key));
        end
        
        function k = get.keywords(obj)
            k = obj.cellArrayFromEnumerable(obj.cobj.Keywords, @char);
        end
        
        function tf = addKeyword(obj, keyword)
            tf = obj.tryCoreWithReturn(@()obj.cobj.AddKeyword(keyword));
        end
        
        function tf = removeKeyword(obj, keyword)
            tf = obj.tryCoreWithReturn(@()obj.cobj.RemoveKeyword(keyword));
        end
        
        function n = get.notes(obj)
            n = obj.cellArrayFromEnumerable(obj.cobj.Notes, @symphonyui.core.persistent.Note);
        end
        
        function n = addNote(obj, text, time)
            if nargin < 3
                time = datetime('now', 'TimeZone', 'local');
            end
            dto = obj.dateTimeOffsetFromDatetime(time);
            cnote = obj.tryCoreWithReturn(@()obj.cobj.AddNote(dto, text));
            n = symphonyui.core.persistent.Note(cnote);
        end
        
    end
    
end