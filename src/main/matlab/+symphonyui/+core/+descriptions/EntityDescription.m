classdef EntityDescription < symphonyui.core.Description
    
    properties (SetAccess = private)
        propertyDescriptors
    end
    
    methods
        
        function obj = EntityDescription()
            obj.propertyDescriptors = symphonyui.core.PropertyDescriptor.empty();
        end
        
        function p = addPropertyDescriptor(obj, name, value, varargin)
            p = symphonyui.core.PropertyDescriptor(name, value, varargin{:});
            obj.propertyDescriptors(end + 1) = p;
        end
        
    end
    
end

