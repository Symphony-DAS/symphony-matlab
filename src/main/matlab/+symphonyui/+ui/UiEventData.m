classdef UiEventData < event.EventData
    
    properties
        data
    end
    
    methods
        
        function obj = UiEventData(data)
            obj.data = data;
        end
        
    end
    
end

