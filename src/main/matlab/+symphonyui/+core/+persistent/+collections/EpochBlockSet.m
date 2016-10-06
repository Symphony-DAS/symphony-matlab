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
            i = '';
            if ~isempty(obj.objects) && all(cellfun(@(b)isequal(b.protocolId, obj.objects{1}.protocolId), obj.objects))
                i = obj.objects{1}.protocolId;
            end
        end
        
        function m = get.protocolParameters(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = obj.objects{1}.protocolParameters;
            for i = 2:numel(obj.objects)
                m = appbox.intersectMaps(m, obj.objects{i}.protocolParameters);
            end
        end
        
    end
    
end

