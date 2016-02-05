classdef EpochGroupDescription < symphonyui.core.persistent.descriptions.EntityDescription
    
    properties
        label
    end
    
    methods
        
        function obj = EpochGroupDescription()
            split = strsplit(class(obj), '.');
            obj.label = appbox.humanize(split{end});
        end
        
        function set.label(obj, l)
            validateattributes(l, {'char'}, {'nonempty', 'row'});
            obj.label = l;
        end
        
    end
    
end

