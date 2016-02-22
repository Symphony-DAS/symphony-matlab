classdef Entity < symphonyui.core.CoreObject

    properties (SetAccess = private)
        uuid
        keywords
        notes
    end

    properties (Constant)
        TYPE_RESOURCE_NAME = 'type'
        PROPERTY_DESCRIPTORS_RESOURCE_NAME = 'propertyDescriptors'
    end

    methods

        function obj = Entity(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end

        function i = get.uuid(obj)
            i = char(obj.cobj.UUID.ToString());
        end

        function addProperty(obj, name, value, varargin)
            descriptors = obj.getPropertyDescriptors();
            if ~isempty(descriptors.findByName(name))
                error([name ' already exists']);
            end
            descriptors(end + 1) = symphonyui.core.PropertyDescriptor(name, value, varargin{:});
            obj.tryCore(@()obj.cobj.AddProperty(name, obj.propertyValueFromValue(value)));
            obj.updateResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME, descriptors);
        end

        function setProperty(obj, name, value)
            descriptors = obj.getPropertyDescriptors();
            d = descriptors.findByName(name);
            if isempty(d)
                error([name ' does not exist']);
            end
            if d.isReadOnly
                error([name ' is read only']);
            end
            d.value = value;
            obj.tryCore(@()obj.cobj.AddProperty(name, obj.propertyValueFromValue(value)));
            obj.updateResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME, descriptors);
        end
        
        function v = getProperty(obj, name)
            descriptors = obj.getPropertyDescriptors();
            d = descriptors.findByName(name);
            if isempty(d)
                error([name ' does not exist']);
            end
            v = d.value;
        end

        function tf = removeProperty(obj, name)
            descriptors = obj.getPropertyDescriptors();
            index = arrayfun(@(d)strcmp(d.name, name), descriptors);
            d = descriptors(index);
            if isempty(d)
                return;
            end
            if ~d.isRemovable
                error([name ' is not removable']);
            end
            descriptors(index) = [];
            tf = obj.tryCoreWithReturn(@()obj.cobj.RemoveProperty(name));
            obj.updateResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME, descriptors);
        end

        function d = getPropertyDescriptors(obj)
            if any(strcmp(obj.getResourceNames(), obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME))
                d = obj.getResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME);
            else
                d = symphonyui.core.PropertyDescriptor.empty(0, 1);
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

        function addResource(obj, name, variable)
            bytes = getByteStreamFromArray(variable);
            obj.tryCoreWithReturn(@()obj.cobj.AddResource('com.mathworks.byte-stream', name, bytes));
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
        
        function t = getType(obj)
            if any(strcmp(obj.getResourceNames(), obj.TYPE_RESOURCE_NAME))
                t = obj.getResource(obj.TYPE_RESOURCE_NAME);
            else
                t = [];
            end
        end

    end

    methods (Static)

        function e = newEntity(cobj, description)
            e = symphonyui.core.persistent.Entity(cobj);

            e.addResource(e.TYPE_RESOURCE_NAME, description.getType());

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
