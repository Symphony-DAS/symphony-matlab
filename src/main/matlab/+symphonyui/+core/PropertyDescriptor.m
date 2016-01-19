classdef PropertyDescriptor < matlab.mixin.SetGet %#ok<*MCSUP>

    properties
        name
        value
        type
        category
        displayName
        description
        isReadOnly
        isHidden
        isPreferred
    end

    properties (Access = private, Transient)
        field
    end

    methods

        function obj = PropertyDescriptor(name, value, varargin)
            if isobject(value)
                error('Value of type object are not supported');
            end
            obj.field = uiextras.jide.PropertyGridField(name, value, ...
                'DisplayName', appbox.humanize(name));
            if nargin > 2
                obj.set(varargin{:});
            end
        end

        function n = get.name(obj)
            n = obj.field.Name;
        end

        function set.name(obj, n)
            obj.field.Name = n;
        end

        function v = get.value(obj)
            v = obj.field.Value;
        end

        function set.value(obj, v)
            if isobject(v)
                error('Value of type object are not supported');
            end
            obj.field.Value = v;
        end

        function t = get.type(obj)
            ft = obj.field.Type;
            t = symphonyui.core.PropertyType(ft.PrimitiveType, ft.Shape, ft.Domain);
        end

        function set.type(obj, t)
            ft = uiextras.jide.PropertyType(t.primitiveType, t.shape, t.domain);
            obj.field.Type = ft;
        end

        function c = get.category(obj)
            c = obj.field.Category;
        end

        function set.category(obj, c)
            obj.field.Category = c;
        end

        function n = get.displayName(obj)
            n = obj.field.DisplayName;
        end

        function set.displayName(obj, n)
            obj.field.DisplayName = n;
        end

        function d = get.description(obj)
            d = obj.field.Description;
        end

        function set.description(obj, d)
            obj.field.Description = d;
        end

        function tf = get.isReadOnly(obj)
            tf = obj.field.ReadOnly;
        end

        function set.isReadOnly(obj, tf)
            obj.field.ReadOnly = tf;
        end

        function tf = get.isHidden(obj)
            tf = obj.field.Hidden;
        end

        function set.isHidden(obj, tf)
            obj.field.Hidden = tf;
        end

        function tf = get.isPreferred(obj)
            tf = obj.field.Preferred;
        end

        function set.isPreferred(obj, tf)
            obj.field.Preferred = tf;
        end

        function p = findByName(array, name)
            p = [];
            for i = 1:numel(array)
                if strcmp(name, array(i).name)
                    p = array(i);
                    return;
                end
            end
        end

        function m = toMap(array)
            m = containers.Map();
            for i = 1:numel(array)
                if ~array(i).isHidden
                    m(array(i).name) = array(i).value;
                end
            end
        end

        function s = saveobj(obj)
            s = struct();
            p = properties(obj);
            for i = 1:numel(p)
                s.(p{i}) = obj.(p{i});
            end
        end

    end

    methods (Static)

        function obj = loadobj(s)
            if isstruct(s)
                obj = symphonyui.core.PropertyDescriptor(s.name, s.value, ...
                    'type', s.type, ...
                    'category', s.category, ...
                    'displayName', s.displayName, ...
                    'description', s.description, ...
                    'isReadOnly', s.isReadOnly, ...
                    'isHidden', s.isHidden, ...
                    'isPreferred', s.isPreferred);
            end
        end

        function obj = fromProperty(handle, property)
            mpo = findprop(handle, property);

            comment = uiextras.jide.helptext([class(handle) '.' mpo.Name]);
            if ~isempty(comment)
                comment{1} = strtrim(regexprep(comment{1}, ['^' mpo.Name ' -'], ''));
            end
            comment = strjoin(comment, '\n');

            obj = symphonyui.core.PropertyDescriptor(mpo.Name, handle.(mpo.Name), ...
                'description', comment, ...
                'isReadOnly', mpo.Constant || ~strcmp(mpo.SetAccess, 'public') || mpo.Dependent && isempty(mpo.SetMethod));

            mto = findprop(handle, [property 'Type']);
            if ~isempty(mto) && mto.Hidden && isa(handle.(mto.Name), 'symphonyui.core.PropertyType')
                obj.type = handle.(mto.Name);
            end
        end

    end

end
