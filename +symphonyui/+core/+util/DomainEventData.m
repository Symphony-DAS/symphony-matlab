classdef DomainEventData < event.EventData
    
    properties
        data
    end
    
    methods
        
        function obj = DomainEventData(data)
            obj.data = data;
        end
        
    end
    
end

