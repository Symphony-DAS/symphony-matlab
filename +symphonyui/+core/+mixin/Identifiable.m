classdef (Abstract) Identifiable < handle
    
    properties (Abstract, Constant)
        displayName
        version
    end
    
    properties (Transient, Hidden)
        id
    end
    
    methods
        
        function setId(obj, id)
            obj.id = id;
        end
        
    end
    
end

