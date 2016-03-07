classdef CoreEventData < event.EventData
    
    properties
        data
    end
    
    methods
        
        function obj = CoreEventData(data)
            obj.data = data;
        end
        
    end
    
end

