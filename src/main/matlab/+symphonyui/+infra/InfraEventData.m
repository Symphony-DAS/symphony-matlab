classdef InfraEventData < event.EventData
    
    properties
        data
    end
    
    methods
        
        function obj = InfraEventData(data)
            obj.data = data;
        end
        
    end
    
end

