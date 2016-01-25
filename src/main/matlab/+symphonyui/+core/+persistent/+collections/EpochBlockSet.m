classdef EpochBlockSet < symphonyui.core.persistent.collections.TimelineEntitySet
    
    properties (SetAccess = private)
        protocolId
        protocolParameters
    end
    
    methods
        
        function obj = EpochBlockSet(blocks)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(blocks);
        end
        
        function i = get.protocolId(obj)
            i = strjoin(unique(cellfun(@(b)b.protocolId, obj.objects, 'UniformOutput', false)), ', ');
        end
        
        function p = get.protocolParameters(obj)
            maps = cell(1, numel(obj.objects));
            for i = 1:numel(obj.objects)
                maps{i} = obj.objects{i}.protocolParameters;
            end
            p = obj.intersectMaps(maps);
        end
        
    end
    
end

