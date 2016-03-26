classdef ProtocolPreset < handle
    
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
        
    end
    
end

