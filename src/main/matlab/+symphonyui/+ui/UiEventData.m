classdef UiEventData < event.EventData
    
    properties
        data
    end
    
    methods
        
        function obj = AppEventData(data)
            obj.data = data;
        end
        
    end
    
end

