classdef EntityDescription < symphonyui.core.Description
    
    properties
        propertyDescriptors
        propertyMap
        resources
    end
    
    methods
        
        function obj = EntityDescription()
            obj.propertyDescriptors = symphonyui.core.PropertyDescriptor.empty(0, 1);
            obj.propertyMap = containers.Map();
            obj.resources = containers.Map();
        end
        
        function set.propertyDescriptors(obj, d)
            validateattributes(d, {'symphonyui.core.PropertyDescriptor'}, {'vector'});
            obj.propertyDescriptors = d;
        end
        
        function set.propertyMap(obj, m)
            validateattributes(m, {'containers.Map'}, {'2d'});
            obj.propertyMap = m;
        end
        
        function set.resources(obj, r)
            validateattributes(r, {'containers.Map'}, {'2d'});
            obj.resources = r;
        end
        
    end
    
end

