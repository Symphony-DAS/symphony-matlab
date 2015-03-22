classdef SourceEventData < event.EventData
    
    properties (SetAccess = private)
        source
    end
    
    methods
        
        function obj = SourceEventData(source)
            obj.source = source;
        end
        
    end
    
end

