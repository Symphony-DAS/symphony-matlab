classdef ProtocolPreset < handle
    
    properties (SetAccess = private)
        name
        propertyMap
    end
    
    methods
        
        function obj = ProtocolPreset(name, propertyMap)
            obj.name = name;
            obj.propertyMap = propertyMap;
        end
        
    end
    
end

