classdef ExperimentFactory < handle
    
    methods
        
        function e = create(obj, name, location, purpose)
            e = symphonyui.core.Experiment(name, location, purpose);
        end
        
        function e = load(obj, path)
            e = symphonyui.core.Experiment('name', 'location');
        end
        
    end
    
end

