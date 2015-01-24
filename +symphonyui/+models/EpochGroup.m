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
        
        function obj = EpochGroup(label, source, keywords, attributes)
            obj.label = label;
            obj.source = source;
            obj.keywords = keywords;
            obj.attributes = attributes;
        end
        
    end
    
end

