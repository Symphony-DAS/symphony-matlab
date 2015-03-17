classdef KeyValueEventData < event.EventData
    
    properties (SetAccess = private)
        key
        value
    end
    
    methods
        
        function obj = KeyValueEventData(key, value)
            obj.key = key;
            obj.value = value;
        end
        
    end
    
end

