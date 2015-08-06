classdef PropertyDescriptor < matlab.mixin.SetGet %#ok<*MCSUP>
    
    properties
        name
        value
        type
        category
        displayName
        description
        readOnly
    end
    
    properties (Access = private, Transient)
        field
    end
    
    methods
        
        function obj = PropertyDescriptor(name, value, varargin)
            obj.field = uiextras.jide.PropertyGridField(name, value);
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
        
        function d = get.description(obj)
            d = obj.field.Description;
        end
        
        function set.description(obj, d)
            obj.field.Description = d;
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
                    'readOnly', s.readOnly);
            end
        end
        
    end
    
end

