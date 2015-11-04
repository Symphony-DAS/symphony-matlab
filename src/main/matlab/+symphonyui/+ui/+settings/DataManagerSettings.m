classdef DataManagerSettings < appbox.Settings
    
    properties
        viewPosition
    end
    
    methods
        
        function p = get.viewPosition(obj)
            p = obj.get('viewPosition');
        end
        
        function set.viewPosition(obj, p)
            validateattributes(p, {'double'}, {'vector'});
            obj.put('viewPosition', p);
        end
        
    end
    
end

