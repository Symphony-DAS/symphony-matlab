classdef EpochSet < symphonyui.core.persistent.collections.TimelineEntitySet
    
    properties (SetAccess = private)
        protocolParameters
    end
    
    methods
        
        function obj = EpochSet(epochs)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(epochs);
        end
        
        function m = get.protocolParameters(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = obj.objects{1}.protocolParameters;
            for i = 2:numel(obj.objects)
                m = obj.intersectMaps(m, obj.objects{i}.protocolParameters);
            end
        end
        
        function m = getStimulusMap(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = cellWrapValues(obj.objects{1}.getStimulusMap());
            for i = 2:numel(obj.objects)
                m = obj.intersectMaps(m, cellWrapValues(obj.objects{i}.getStimulusMap()), true);
            end
        end
        
        function m = getResponseMap(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = cellWrapValues(obj.objects{1}.getResponseMap());
            for i = 2:numel(obj.objects)
                m = obj.intersectMaps(m, cellWrapValues(obj.objects{i}.getResponseMap()), true);
            end
        end
        
        function m = getBackgroundMap(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = cellWrapValues(obj.objects{1}.getBackgroundMap());
            for i = 2:numel(obj.objects)
                m = obj.intersectMaps(m, cellWrapValues(obj.objects{i}.getBackgroundMap()), true);
            end
        end
        
    end
    
end

function m = cellWrapValues(m)
    keys = m.keys;
    for i = 1:numel(keys)
        k = keys{i};
        m(k) = {m(k)};
    end
end
