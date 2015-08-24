classdef EpochBlockSet < symphonyui.core.collections.TimelineEntitySet
    
    properties (SetAccess = private)
        protocolId
        protocolParameters
    end
    
    methods
        
        function obj = EpochBlockSet(blocks)
            obj@symphonyui.core.collections.TimelineEntitySet(blocks);
        end
        
        function i = get.protocolId(obj)
            i = strjoin(unique(cellfun(@(b)b.protocolId, obj.entities, 'UniformOutput', false)), ', ');
        end
        
        function p = get.protocolParameters(obj)
            maps = cell(1, numel(obj.entities));
            for i = 1:numel(obj.entities)
                maps{i} = obj.entities{i}.protocolParameters;
            end
            p = obj.intersectMaps(maps);
        end
        
    end
    
end

