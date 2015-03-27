classdef Animal < symphonyui.core.Source
    
    properties
        species = 'C57BL/6'
    end
    
    methods
        
        function p = getProperty(obj, name)
            import symphonyui.core.PropertyType;
            
            p = getProperty@symphonyui.core.Source(obj, name);
            
            switch name
                case 'phenotype'
                    p.type = PropertyType('char', 'row', {'Amplifier_Ch1', 'Amplifier_Ch2'});
            end
        end
        
    end
    
end

