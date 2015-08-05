classdef FileDescription < symphonyui.core.Description
    
    properties
        experimentDescription
    end
    
    methods
        
        function obj = FileDescription()
            obj.experimentDescription = symphonyui.core.descriptions.ExperimentDescription();
        end
        
    end
    
end

