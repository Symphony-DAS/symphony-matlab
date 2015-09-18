classdef AddSourceSettings < symphonyui.infra.Settings
    
    properties
        selectedParentUuid
        selectedDescription
    end
    
    methods
        
        function i = get.selectedParentUuid(obj)
            i = obj.get('selectedParentUuid');
        end
        
        function set.selectedParentUuid(obj, i)
            validateattributes(i, {'char'}, {});
            obj.put('selectedParentUuid', i);
        end
        
        function d = get.selectedDescription(obj)
            d = obj.get('selectedDescription');
        end
        
        function set.selectedDescription(obj, d)
            validateattributes(d, {'char'}, {'row'});
            obj.put('selectedDescription', d);
        end
        
    end
    
end

