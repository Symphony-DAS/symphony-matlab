% http://precedings.nature.com/documents/1720/version/2/files/npre20091720-2.pdf

classdef Electrophysiology < symphonyui.core.descriptions.ExperimentDescription
    
    methods
        
        function obj = Electrophysiology()
            import symphonyui.core.PropertyType;
            
            obj.addPropertyDescriptor('responsiblePerson', '', ...
                'description', 'The (stable) primary contact person for this data set; this could be the experimenter, lab head, line manager etc.');
            obj.addPropertyDescriptor('experimentalContext', '', ...
                'description', 'The name of the project, study or wider investigation of which the experiment is a part.');
            obj.addPropertyDescriptor('electrophysiologyType', 'extra cellular', ...
                'type', PropertyType('char', 'row', {'extra cellular', 'intra cellular'}), ...
                'description', 'The type of electrophysiology recording reported as ''extra cellular'' or ''intra cellular''.');
        end
        
    end
    
end

