classdef Standard < symphonyui.core.descriptions.EpochGroupDescription
    
    methods
        
        function obj = Standard()
            import symphonyui.core.*;
            
            obj.propertyDescriptors = [ ...
                PropertyDescriptor('ndfs', {}, ...
                    'type', PropertyType('cellstr', 'row', {'0.3', '0.6', '1.2', '3.0', '4.0'}), ...
                    'description', 'The name of the project this experiment belongs to.'), ...
                PropertyDescriptor('solution', '', ...
                    'description', 'Description of the solutions used in terms of name, components with concentrations'), ...
                ];
        end
        
    end
    
end

