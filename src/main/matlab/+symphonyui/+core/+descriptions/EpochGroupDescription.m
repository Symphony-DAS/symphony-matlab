classdef EpochGroupDescription < symphonyui.core.descriptions.EntityDescription
    
    properties
        label
    end
    
    methods
        
        function obj = EpochGroupDescription()
            obj.label = obj.displayName;
        end
        
    end
    
end

