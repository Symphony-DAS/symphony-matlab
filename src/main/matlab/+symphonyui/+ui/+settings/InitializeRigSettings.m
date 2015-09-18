classdef InitializeRigSettings < symphonyui.infra.Settings
    
    properties
        selectedDescription
    end
    
    methods
        
        function d = get.selectedDescription(obj)
            d = obj.get('selectedDescription');
        end
        
        function set.selectedDescription(obj, d)
            validateattributes(d, {'char'}, {'row'});
            obj.put('selectedDescription', d);
        end
        
    end
    
end

