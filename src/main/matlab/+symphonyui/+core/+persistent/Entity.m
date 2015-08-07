classdef Entity < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        uuid
        propertyMap
        keywords
        notes
    end
    
    properties (Access = private)
        staticPropertyDescriptors
    end
    
    properties (Constant, Access = private)
        DESCRIPTION_TYPE_KEY = 'descriptionType'
        STATIC_PROPERTY_DESCRIPTORS_NAME = 'descriptors'
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
            if strcmp(key, obj.DESCRIPTION_TYPE_KEY)
                error('Cannot remove the description type property');
            end
            desc = obj.getStaticPropertyDescriptors();
            if ~isempty(desc.findByName(key))
                error('Cannot remove a property with a descriptor');
            end
            tf = obj.tryCoreWithReturn(@()obj.cobj.RemoveProperty(key));
        end
        
        function p = getPropertyDescriptors(obj)
            desc = obj.getStaticPropertyDescriptors(); 
            map = obj.propertyMap;
            keys = map.keys;
            p = symphonyui.core.PropertyDescriptor.empty(0, numel(keys));
            for i = 1:numel(keys)
                d = desc.findByName(keys{i});
                if isempty(d)
                    p(i) = symphonyui.core.PropertyDescriptor(keys{i}, map(keys{i}), ...
                        'readOnly', true);
                else
                    d.value = map(d.name);
                    p(i) = d;
                end
            end
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
        
        function addResource(obj, name, variable) %#ok<INUSD>
            temp = [tempname '.mat'];
            save(temp, 'variable');
            file = java.io.File(temp);
            bytes = typecast(java.nio.file.Files.readAllBytes(file.toPath), 'uint8');
            delete(temp);
            obj.tryCoreWithReturn(@()obj.cobj.AddResource('com.mathworks.workspace', name, bytes));
        end
        
        function v = getResource(obj, name)
            cres = obj.tryCoreWithReturn(@()obj.cobj.GetResource(name));
            temp = [tempname '.mat'];
            fid = fopen(temp, 'w');
            fwrite(fid, uint8(cres.Data));
            fclose(fid);
            s = load(temp);
            delete(temp);
            v = s.variable;
        end
        
        function n = getResourceNames(obj)
            n = obj.cellArrayFromEnumerable(obj.cobj.GetResourceNames(), @char);
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
    
    methods (Access = private)
        
        function p = getStaticPropertyDescriptors(obj)
            if isempty(obj.staticPropertyDescriptors)
                if any(strcmp(obj.STATIC_PROPERTY_DESCRIPTORS_NAME, obj.getResourceNames()))
                    d = obj.getResource(obj.STATIC_PROPERTY_DESCRIPTORS_NAME);
                else
                    d = symphonyui.core.PropertyDescriptor.empty();
                end
                obj.staticPropertyDescriptors = d;
            end
            p = obj.staticPropertyDescriptors;
        end
        
    end
    
    methods (Static)
        
        function e = newEntity(cobj, description)
            e = symphonyui.core.persistent.Entity(cobj);
            
            descriptors = description.propertyDescriptors;
            e.addResource(e.STATIC_PROPERTY_DESCRIPTORS_NAME, descriptors);
            
            for i = 1:numel(descriptors)
                desc = descriptors(i);
                e.addProperty(desc.name, desc.value);
            end
            e.addProperty(e.DESCRIPTION_TYPE_KEY, class(description));
        end
        
    end
    
end