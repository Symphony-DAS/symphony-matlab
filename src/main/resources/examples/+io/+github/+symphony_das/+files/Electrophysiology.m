classdef Electrophysiology < symphonyui.core.descriptions.FileDescription
    
    methods
        
        function obj = Electrophysiology()
            obj.experimentDescription = io.github.symphony_das.experiments.Electrophysiology();
        end
        
    end
    
end

