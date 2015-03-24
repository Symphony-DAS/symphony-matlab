classdef PropertyEventData < event.EventData
    
    properties (SetAccess = private)
        name
    end
    
    methods
        
        function obj = PropertyEventData(name)
            obj.name = name;
        end
        
    end
    
end

