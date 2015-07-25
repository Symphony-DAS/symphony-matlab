classdef SourceDescription < symphonyui.core.descriptions.EntityDescription
    
    properties
        label
    end
    
    methods
        
        function obj = SourceDescription()
            obj.label = obj.displayName;
        end
        
    end
    
end

