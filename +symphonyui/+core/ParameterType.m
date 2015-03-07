classdef ParameterType < handle
    
    properties
        primitiveType
        shape
        domain
    end
    
    properties (Access = private)
        propertyType
    end
    
    methods
        
        function obj = ParameterType(type, shape, domain)
            if nargin < 3
                domain = [];
            end
            
            try
                obj.propertyType = PropertyType(type, shape, domain);
            catch x
                throw(x);
            end
        end
        
    end
    
    methods
        
        function p = get.primitiveType(obj)
            p = obj.propertyType.PrimitiveType;
        end
        
        function set.primitiveType(obj, p)
            try
                obj.propertyType.PrimitiveType = p; %#ok<MCSUP>
            catch
                throw(x);
            end
        end
        
        function s = get.shape(obj)
            s = obj.propertyType.Shape;
        end
        
        function set.shape(obj, s)
            try
                obj.propertyType.Shape = s; %#ok<MCSUP>
            catch x
                throw(x);
            end
        end
        
        function d = get.domain(obj)
            d = obj.propertyType.Domain;
        end
        
        function set.domain(obj, d)
            try
                obj.propertyType.Domain = d; %#ok<MCSUP>
            catch x
                throw(x);
            end
        end
        
    end
    
    methods (Static)
        
        function obj = autoDiscover(value)
            try
                t = PropertyType.AutoDiscoverType(value);
            catch x
                throw(x);
            end
            
            try
                s = PropertyType.AutoDiscoverShape(value);
            catch x
                throw(x);
            end
            
            obj = symphonyui.core.ParameterType(t, s);
        end
        
    end
    
end

