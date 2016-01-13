classdef PropertyType < matlab.mixin.SetGet %#ok<*MCSUP>
    
    properties
        primitiveType
        shape
        domain
    end
    
    properties (Access = private, Transient)
        type
    end
    
    methods
        
        function obj = PropertyType(primitiveType, shape, domain)
            if strcmp(primitiveType, 'object')
                error('Type of object is not supported');
            end
            if nargin < 3
                domain = [];
            end
            obj.type = uiextras.jide.PropertyType(primitiveType, shape, domain);
        end
        
        function set.primitiveType(obj, t)
            if strcmp(t, 'object')
                error('Type of object is not supported');
            end
            obj.type.PrimitiveType = t; 
        end
        
        function t = get.primitiveType(obj)
            t = obj.type.PrimitiveType;
        end
        
        function set.shape(obj, s)
            obj.type.Shape = s;
        end
        
        function s = get.shape(obj)
            s = obj.type.Shape;
        end
        
        function set.domain(obj, d)
            obj.type.Domain = d;
        end
        
        function d = get.domain(obj)
            d = obj.type.Domain;
        end
        
        function tf = canAccept(obj, value)
            tf = obj.type.CanAccept(value);
        end
        
        function s = saveobj(obj)
            s.primitiveType = obj.primitiveType;
            s.shape = obj.shape;
            s.domain = obj.domain;
        end
        
    end
    
    methods (Static)
        
        function obj = loadobj(s)
            if isstruct(s)
                obj = symphonyui.core.PropertyType(s.primitiveType, s.shape, s.domain);
            end
        end
        
        function t = autoDiscover(value)
            pt = uiextras.jide.PropertyType.AutoDiscover(value);
            t = symphonyui.core.PropertyType(pt.PrimitiveType, pt.Shape, pt.Domain);
        end
        
    end
    
end

