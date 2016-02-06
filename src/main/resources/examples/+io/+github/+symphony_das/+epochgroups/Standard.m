classdef Standard < symphonyui.core.persistent.descriptions.EpochGroupDescription
    
    methods
        
        function obj = Standard()
            import symphonyui.core.*;
            
            obj.addProperty('solution', '', ...
                'description', 'Description of the solutions used in terms of name, components with concentrations');
            
            obj.addAllowableParentType([]);
        end
        
    end
    
end

