classdef FileDescription < symphonyui.core.Description
    
    properties
        experimentDescription
    end
    
    methods
        
        function obj = FileDescription()
            obj.experimentDescription = symphonyui.core.descriptions.ExperimentDescription();
        end
        
        function set.experimentDescription(obj, d)
            validateattributes(d, {'symphonyui.core.descriptions.ExperimentDescription'}, {'scalar'});
            obj.experimentDescription = d;
        end
        
    end
    
end

