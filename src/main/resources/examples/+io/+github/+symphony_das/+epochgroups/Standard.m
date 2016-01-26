classdef Standard < symphonyui.core.descriptions.EpochGroupDescription
    
    methods
        
        function obj = Standard()
            import symphonyui.core.*;
            
            obj.propertyDescriptors = [ ...
                PropertyDescriptor('solution', '', ...
                    'description', 'Description of the solutions used in terms of name, components with concentrations'), ...
                ];
        end
        
    end
    
end

