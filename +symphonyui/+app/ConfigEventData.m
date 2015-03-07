classdef ConfigEventData < event.EventData
    
    properties (SetAccess = private)
        key
    end
    
    methods
        
        function obj = ConfigEventData(key)
            obj.key = key;
        end
        
    end
    
end

