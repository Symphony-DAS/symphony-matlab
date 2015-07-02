classdef Entity < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        uuid
        propertiesMap
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
        
        function p = get.propertiesMap(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.Properties);
        end
        
        function addProperty(obj, key, value)
            obj.cobj.AddProperty(key, value);
        end
        
        function tf = removeProperty(obj, key)
            tf = obj.cobj.RemoveProperty(key);
        end
        
        function k = get.keywords(obj)
            k = obj.cellArrayFromEnumerable(obj.cobj.Keywords);
        end
        
        function addKeyword(obj, keyword)
            obj.cobj.AddKeyword(keyword);
        end
        
        function tf = removeKeyword(obj, keyword)
            tf = obj.cobj.RemoveKeyword(keyword);
        end
        
        function n = get.notes(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.Notes);
            n = cell(1, numel(c));
            for i = 1:numel(c)
                n{i} = symphonyui.core.persistent.Note(c{i});
            end
        end
        
        function addNote(obj, text, time)
            if nargin < 3
                time = datetime('now', 'TimeZone', 'local');
            end
            dto = obj.dateTimeOffsetFromDatetime(time);
            obj.cobj.AddNote(dto, text);
        end
        
    end
    
end

