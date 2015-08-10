classdef EpochGroupDescription < symphonyui.core.descriptions.EntityDescription
    
    properties
        label
    end
    
    methods
        
        function obj = EpochGroupDescription()
            obj.label = obj.displayName;
        end
        
        function set.label(obj, l)
            validateattributes(l, {'char'}, {'nonempty', 'row'});
            obj.label = l;
        end
        
    end
    
end

