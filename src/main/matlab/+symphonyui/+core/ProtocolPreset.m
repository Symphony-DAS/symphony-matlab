classdef ProtocolPreset < handle
    % A ProtocolPreset stores a set of property values for a protocol.
    
    properties (SetAccess = private)
        name
        protocolId
        propertyMap
    end
    
    methods
        
        function obj = ProtocolPreset(name, protocolId, propertyMap)
            obj.name = name;
            obj.protocolId = protocolId;
            obj.propertyMap = propertyMap;
        end
        
        function s = toStruct(obj)
            s.name = obj.name;
            s.protocolId = obj.protocolId;
            s.propertyMap = obj.propertyMap;
        end
        
    end
    
    methods (Static)
        
        function obj = fromStruct(s)
            obj = symphonyui.core.ProtocolPreset(s.name, s.protocolId, s.propertyMap);
        end
        
    end
    
end

