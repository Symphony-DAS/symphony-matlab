classdef EntityDescription < symphonyui.core.Description
    
    properties (Access = private)
        propertyDescriptors
        resources
    end
    
    methods
        
        function obj = EntityDescription()
            obj.propertyDescriptors = symphonyui.core.PropertyDescriptor.empty(0, 1);
            obj.resources = containers.Map();
        end
        
        function addProperty(obj, name, value, varargin)
            d = symphonyui.core.PropertyDescriptor(name, value, varargin{:});
            obj.propertyDescriptors(end + 1) = d;
        end
        
        function d = getPropertyDescriptors(obj)
            d = obj.propertyDescriptors;
        end
        
        function addResource(obj, name, variable)
            obj.resources(name) = variable;
        end
        
        function v = getResource(obj, name)
            v = obj.resources(name);
        end
        
        function n = getResourceNames(obj)
            n = obj.resources.keys;
        end
        
        function t = getType(obj)
            t = class(obj);
        end
        
    end
    
end

