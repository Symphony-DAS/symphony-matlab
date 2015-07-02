classdef PropertyEventData < event.EventData
    
    properties (SetAccess = private)
        Property
    end
    
    methods
        
        function obj = PropertyEventData(property)
            obj.Property = property;
        end
        
    end
    
end

