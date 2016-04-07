classdef BeginEpochGroupSettings < appbox.Settings
    
    properties
        carryForwardProperties
    end
    
    methods
        
        function tf = get.carryForwardProperties(obj)
            tf = obj.get('enableCarryForwardProperties', true);
        end
        
        function set.carryForwardProperties(obj, tf)
            validateattributes(tf, {'double', 'logical'}, {'scalar'});
            obj.put('enableCarryForwardProperties', tf);
        end
        
    end
    
end

