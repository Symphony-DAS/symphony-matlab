classdef EntityPreset < handle
    
    properties (SetAccess = private)
        name
        entityType
        descriptionType
        classProperties
        propertyMap
    end
    
    methods
        
        function obj = EntityPreset(name, entityType, descriptionType, classProperties, propertyMap)
            obj.name = name;
            obj.entityType = entityType;
            obj.descriptionType = descriptionType;
            obj.classProperties = classProperties;
            obj.propertyMap = propertyMap;
        end
        
        function s = toStruct(obj)
            s.name = obj.name;
            s.entityType = obj.entityType;
            s.descriptionType = obj.descriptionType;
            s.classProperties = obj.classProperties;
            s.propertyMap = obj.propertyMap;
        end
        
    end
    
    methods (Static)
        
        function obj = fromStruct(s)
            obj = symphonyui.core.persistent.EntityPreset(s.name, s.entityType, s.descriptionType, s.classProperties, s.propertyMap);
        end
        
    end
    
end

