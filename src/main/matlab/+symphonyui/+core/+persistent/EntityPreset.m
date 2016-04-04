classdef EntityPreset < handle
    
    properties (SetAccess = private)
        name
        entityType
        descriptionType
        propertyMap
    end
    
    methods
        
        function obj = EntityPreset(name, entityType, descriptionType, propertyMap)
            obj.name = name;
            obj.entityType = entityType;
            obj.descriptionType = descriptionType;
            obj.propertyMap = propertyMap;
        end
        
        function s = toStruct(obj)
            s.name = obj.name;
            s.entityType = obj.entityType;
            s.descriptionType = obj.descriptionType;
            s.propertyMap = obj.propertyMap;
        end
        
    end
    
    methods (Static)
        
        function obj = fromStruct(s)
            obj = symphonyui.core.persistent.EntityPreset(s.name, s.entityType, s.descriptionType, s.propertyMap);
        end
        
    end
    
end

