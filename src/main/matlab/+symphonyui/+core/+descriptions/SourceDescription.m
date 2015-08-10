classdef SourceDescription < symphonyui.core.descriptions.EntityDescription
    
    properties
        label
    end
    
    methods
        
        function obj = SourceDescription()
            obj.label = obj.displayName;
        end
        
        function set.label(obj, l)
            validateattributes(l, {'char'}, {'nonempty', 'row'});
            obj.label = l;
        end
        
    end
    
end

