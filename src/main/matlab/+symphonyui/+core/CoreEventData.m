classdef CoreEventData < event.EventData
    % Event data for events triggered by the domain layer.
    
    properties
        data
    end
    
    methods
        
        function obj = CoreEventData(data)
            obj.data = data;
        end
        
    end
    
end

