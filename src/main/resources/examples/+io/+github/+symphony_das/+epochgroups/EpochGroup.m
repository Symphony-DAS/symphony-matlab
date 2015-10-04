classdef EpochGroup < symphonyui.core.descriptions.EpochGroupDescription
    
    methods
        
        function obj = EpochGroup()
            import symphonyui.core.*;
            
            obj.propertyDescriptors = [ ...
                PropertyDescriptor('ndfs', [false false false false false], ...
                    'type', PropertyType('logical', 'row', {'0.3', '0.6', '1.2', '3.0', '4.0'}), ...
                    'description', 'The name of the project this experiment belongs to.'), ...
                PropertyDescriptor('solution', '', ...
                    'description', 'Description of the solutions used in terms of name, components with concentrations'), ...
                ];
        end
        
    end
    
end

