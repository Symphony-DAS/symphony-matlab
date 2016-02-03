classdef Entity < symphonyui.core.CoreObject

    properties (SetAccess = private)
        uuid
        keywords
        notes
    end

    properties (Access = private)
        propertyDescriptors
    end

    properties (Constant)
        DESCRIPTION_TYPE_RESOURCE_NAME = 'descriptionType'
        PROPERTY_DESCRIPTORS_RESOURCE_NAME = 'propertyDescriptors'
    end

    methods

        function obj = Entity(cobj)
            obj@symphonyui.core.CoreObject(cobj);
            if any(strcmp(obj.getResourceNames(), obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME))
                obj.propertyDescriptors = obj.getResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME);
            else
                obj.propertyDescriptors = symphonyui.core.PropertyDescriptor.empty(0, 1);
            end
        end

        function i = get.uuid(obj)
            i = char(obj.cobj.UUID.ToString());
        end

        function addProperty(obj, name, value, varargin)
            if obj.isProperty(name)
                error([name ' already exists']);
            end
            d = symphonyui.core.PropertyDescriptor(name, value, varargin{:});
            obj.tryCore(@()obj.cobj.AddProperty(name, obj.propertyValueFromValue(value)));
            obj.propertyDescriptors(end + 1) = d;
            obj.updateResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME, obj.propertyDescriptors);
        end
        
        function setProperty(obj, name, value)
            if ~obj.isProperty(name)
                error([name ' does not exist']);
            end
            obj.propertyDescriptors.findByName(name).value = value;
            obj.tryCore(@()obj.cobj.AddProperty(name, obj.propertyValueFromValue(value)));
            obj.updateResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME, obj.propertyDescriptors);
        end

        function tf = removeProperty(obj, name)
            tf = obj.tryCoreWithReturn(@()obj.cobj.RemoveProperty(name));
            index = arrayfun(@(d)strcmp(d.name, name), obj.propertyDescriptors);
            obj.propertyDescriptors(index) = [];
            obj.updateResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME, obj.propertyDescriptors);
        end
        
        function tf = isProperty(obj, name)
            tf = ~isempty(obj.propertyDescriptors.findByName(name));
        end

        function d = getPropertyDescriptors(obj)
            d = obj.propertyDescriptors;
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

        function addResource(obj, name, variable)
            bytes = getByteStreamFromArray(variable);
            obj.tryCoreWithReturn(@()obj.cobj.AddResource('com.mathworks.workspace', name, bytes));
        end
        
        function updateResource(obj, name, variable)
            obj.removeResource(name);
            obj.addResource(name, variable);
        end

        function v = getResource(obj, name)
            cres = obj.tryCoreWithReturn(@()obj.cobj.GetResource(name));
            v = getArrayFromByteStream(uint8(cres.Data));
        end
        
        function tf = removeResource(obj, name)
            tf = obj.tryCoreWithReturn(@()obj.cobj.RemoveResource(name));
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

    methods (Static)

        function e = newEntity(cobj, description)
            e = symphonyui.core.persistent.Entity(cobj);
            
            e.addResource(e.DESCRIPTION_TYPE_RESOURCE_NAME, class(description));            
            
            descriptors = description.getPropertyDescriptors();
            for i = 1:numel(descriptors)
                e.tryCore(@()e.cobj.AddProperty(descriptors(i).name, e.propertyValueFromValue(descriptors(i).value)));
            end
            e.addResource(e.PROPERTY_DESCRIPTORS_RESOURCE_NAME, descriptors);
            
            names = description.getResourceNames();
            for i = 1:numel(names)
                e.addResource(names{i}, description.getResource(names{i}));
            end
        end

    end

end