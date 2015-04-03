classdef ExperimentFactory < handle
    
    methods
        
        function e = create(obj, name, location)
            e = symphonyui.core.Experiment(name, location);
        end
        
        function e = open(obj, path)
            e = symphonyui.core.Experiment('name', 'location');
        end
        
    end
    
end

