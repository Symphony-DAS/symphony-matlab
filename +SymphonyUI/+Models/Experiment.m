classdef Experiment < handle
    
    properties
        path
        rig
        purpose
    end
    
    properties (SetObservable)
        epochGroup
    end
    
    methods
        
        function obj = Experiment(path, rig, purpose)
            obj.path = path;
            obj.rig = rig;
            obj.purpose = purpose;
        end
        
        function addNote(obj, note)
            
        end
        
    end
    
end

