classdef Subject < symphonyui.core.descriptions.SourceDescription
    
    methods
        
        function obj = Subject()
            import symphonyui.core.PropertyType;
            
            obj.addPropertyDescriptor('genus', 'homo', ...
                'type', PropertyType('char', 'row', {'homo', 'macaca', 'mus', 'ovis', 'rattus'}), ...
                'description', 'The genus classification of the study subject according to the NCBI taxonomy classification.');
            obj.addPropertyDescriptor('species', '', ...
                'description', 'The species classification of the study subject according to the NCBI taxonomy classification.');
            
        end
        
    end
    
end

