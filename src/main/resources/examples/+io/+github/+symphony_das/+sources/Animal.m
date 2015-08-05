classdef Animal < symphonyui.core.descriptions.SourceDescription
    
    methods
        
        function obj = Animal()
            import symphonyui.core.PropertyDescriptor;
            
            obj.propertyDescriptors = [ ...
                PropertyDescriptor('one', 1), ...
                PropertyDescriptor('two', 'second')];
        end
        
    end
    
end

