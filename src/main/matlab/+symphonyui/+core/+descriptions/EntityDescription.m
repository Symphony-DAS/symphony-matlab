classdef EntityDescription < symphonyui.core.Description
    
    properties
        propertyDescriptors
    end
    
    methods
        
        function obj = EntityDescription()
            obj.propertyDescriptors = symphonyui.core.PropertyDescriptor.empty(0, 1);
        end
        
        function set.propertyDescriptors(obj, d)
            validateattributes(d, {'symphonyui.core.PropertyDescriptor'}, {'vector'});
            obj.propertyDescriptors = d;
        end
        
    end
    
end

