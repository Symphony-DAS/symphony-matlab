classdef EpochGroup < handle
    
    properties
        label
        source
        keywords
        attributes
        
        parent
        children
    end
    
    methods
        
        function obj = EpochGroup(label)
            obj.label = label;
        end
        
    end
    
end

