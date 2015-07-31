classdef EpochBlockSet < symphonyui.core.collections.TimelineEntitySet
    
    properties (SetAccess = private)
        protocolId
    end
    
    methods
        
        function obj = EpochBlockSet(blocks)
            obj@symphonyui.core.collections.TimelineEntitySet(blocks);
        end
        
        function i = get.protocolId(obj)
            i = strjoin(unique(cellfun(@(b)b.protocolId, obj.entities, 'UniformOutput', false)), ', ');
        end
        
    end
    
end

