classdef PropertyType < matlab.mixin.SetGet %#ok<*MCSUP>
    % A PropertyType encapsulates the primitive type, shape and domain constraints on a property value.
    %
    % Examples:
    %   PropertyType('denserealsingle', 'scalar')
    %       Creates a non-sparse single real scalar with unrestricted value
    %   PropertyType('denserealdouble', 'scalar', [-1, 1])
    %       Creates a non-sparse double real scalar with value in range -1 to 1
    %   PropertyType('char', 'row', {'spring', 'summer', 'fall', 'winter'})
    %       Creates a character array which may be either be 'spring', 'summer', 'fall' or 'winter'
    %   PropertyType('logical', 'column', {'A', 'B', 'C'})
    %       Creates a set whose elements are 'A', 'B' and 'C'
    
    properties
        primitiveType   % Underlying Matlab type for the property
        shape           % Expected dimension for thr property
        domain          % Domain of possible property values
    end
    
    properties (Access = private, Transient)
        type
    end
    
    methods
        
        function obj = PropertyType(primitiveType, shape, domain)
            if nargin == 1 && isa(primitiveType, 'uiextras.jide.PropertyType')
                obj.type = primitiveType;
                return;
            end
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
            t = symphonyui.core.PropertyType(pt);
        end
        
    end
    
end

