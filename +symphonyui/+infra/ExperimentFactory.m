classdef ExperimentFactory < handle
    
    methods
        
        function e = create(obj, name, location, purpose)
            e = symphonyui.core.Experiment(name, location, purpose);
        end
        
        function e = open(obj, path)
            e = symphonyui.core.Experiment('name', 'location', 'purpose');
        end
        
    end
    
end

