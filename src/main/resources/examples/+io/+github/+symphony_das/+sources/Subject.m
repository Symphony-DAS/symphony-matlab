classdef Subject < symphonyui.core.persistent.descriptions.SourceDescription
    
    methods
        
        function obj = Subject()
            import symphonyui.core.*;
            
            obj.addProperty('id', '', ...
                'description', 'ID of animal/person (lab convention)');
            obj.addProperty('description', '', ...
                'description', 'Description of subject and where subject came from (eg, breeder, if animal)');
            obj.addProperty('species', '', ...
                'description', 'Species');
            obj.addProperty('genotype', '', ...
                'description', 'Genetic strain');
            obj.addProperty('sex', '', ...
                'type', PropertyType('char', 'row', {'', 'male', 'female', 'hermaphrodite'}));
            obj.addProperty('age', '', ...
                'description', 'Age of person, animal, embryo');
            obj.addProperty('weight', '', ...
                'description', 'Weight at time of experiment, at time of surgery, and at other important times');
            
            obj.addAllowableParentType([]);
        end
        
    end
    
end

