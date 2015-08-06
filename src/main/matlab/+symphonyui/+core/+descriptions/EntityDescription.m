classdef EntityDescription < symphonyui.core.Description
    
    properties
        propertyDescriptors
    end
    
    methods
        
        function obj = EntityDescription()
            obj.propertyDescriptors = symphonyui.core.PropertyDescriptor.empty();
        end
        
    end
    
end

