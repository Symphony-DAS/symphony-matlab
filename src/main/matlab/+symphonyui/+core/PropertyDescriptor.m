classdef PropertyDescriptor < matlab.mixin.SetGet %#ok<*MCSUP>
    
    properties
        name
        value
        type
        category
        displayName
        description
        readOnly
        hidden
        preferred
    end
    
    properties (Access = private, Transient)
        field
    end
    
    methods
        
        function obj = PropertyDescriptor(name, value, varargin)
            obj.field = uiextras.jide.PropertyGridField(name, value, ...
                'DisplayName', symphonyui.core.util.humanize(name));
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
            if isempty(v) && ~ischar(v)
                v = [];
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
        
        function tf = get.readOnly(obj)
            tf = obj.field.ReadOnly;
        end
        
        function set.readOnly(obj, tf)
            obj.field.ReadOnly = tf;
        end
        
        function tf = get.hidden(obj)
            tf = obj.field.Hidden;
        end
        
        function set.hidden(obj, tf)
            obj.field.Hidden = tf;
        end
        
        function tf = get.preferred(obj)
            tf = obj.field.Preferred;
        end
        
        function set.preferred(obj, tf)
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
                    'readOnly', s.readOnly, ...
                    'hidden', s.hidden, ...
                    'preferred', s.preferred);
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
                'readOnly', mpo.Constant || ~strcmp(mpo.SetAccess, 'public') || mpo.Dependent && isempty(mpo.SetMethod));
            
            mto = findprop(handle, [property 'Type']);
            if ~isempty(mto) && mto.Hidden && isa(handle.(mto.Name), 'symphonyui.core.PropertyType')
                obj.type = handle.(mto.Name);
            end
            
            mso = findprop(handle, [property 'Set']);
            if ~isempty(mso) && mso.Hidden && isa(handle.(mso.Name), 'symphonyui.core.StringSet')
                obj.type = handle.(mso.Name).type;
            end
        end
        
    end
    
end

