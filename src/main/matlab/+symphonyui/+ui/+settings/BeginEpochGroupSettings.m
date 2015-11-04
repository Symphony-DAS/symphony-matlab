classdef BeginEpochGroupSettings < appbox.Settings
    
    properties
        selectedSourceUuid
        selectedDescription
    end
    
    methods
        
        function i = get.selectedSourceUuid(obj)
            i = obj.get('selectedSourceUuid');
        end
        
        function set.selectedSourceUuid(obj, i)
            validateattributes(i, {'char'}, {'2d'});
            obj.put('selectedSourceUuid', i);
        end
        
        function d = get.selectedDescription(obj)
            d = obj.get('selectedDescription');
        end
        
        function set.selectedDescription(obj, d)
            validateattributes(d, {'char'}, {'2d'});
            obj.put('selectedDescription', d);
        end
        
    end
    
end

