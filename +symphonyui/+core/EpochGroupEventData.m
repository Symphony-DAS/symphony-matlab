classdef EpochGroupEventData < event.EventData
    
    properties (SetAccess = private)
        epochGroup
    end
    
    methods
        
        function obj = EpochGroupEventData(group)
            obj.epochGroup = group;
        end
        
    end
    
end

