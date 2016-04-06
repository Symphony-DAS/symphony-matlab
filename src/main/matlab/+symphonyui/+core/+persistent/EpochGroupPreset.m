classdef EpochGroupPreset < symphonyui.core.persistent.EntityPreset
    
    properties
        label
    end
    
    methods
        
        function obj = EpochGroupPreset(name, descriptionType, propertyMap, label)
            entityType = symphonyui.core.persistent.EntityType.EPOCH_GROUP;
            obj@symphonyui.core.persistent.EntityPreset(name, entityType, descriptionType, propertyMap);
            obj.label = label;
        end
        
        function s = toStruct(obj)
            s = toStruct@symphonyui.core.persistent.EntityPreset(obj);
            s.label = obj.label;
        end
        
    end
    
    methods (Static)
        
        function obj = fromStruct(s)
            obj = symphonyui.core.persistent.EpochGroupPreset(s.name, s.entityType, s.descriptionType, s.propertyMap, s.label);
        end
        
    end
    
end

