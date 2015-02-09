classdef Preset < handle
    
    properties
        displayName
        valueMap
    end
    
    methods
        
        function obj = ProtocolPreset(displayName, valueMap)
            obj.displayName = displayName;
            obj.valueMap = valueMap;
        end
        
        function apply(obj, protocol)
            parameters = protocol.getParameters();
            for i = 1:numel(parameters)
                p = parameters(i);
                if obj.valueMap.isKey(p.name) && ~p.isReadOnly
                    protocol.(p.name) = obj.valueMap(p.name);
                end
            end
        end
        
    end
    
    methods (Static)
        
        function obj = fromProtocol(displayName, protocol)
            map = containers.Map();
            parameters = protocol.getParameters();
            for i = 1:numel(parameters)
                p = parameters(i);
                map(p.name) = p.value;
            end
            obj = symphonyui.models.ProtocolPreset(displayName, map);
        end
        
    end
    
end

