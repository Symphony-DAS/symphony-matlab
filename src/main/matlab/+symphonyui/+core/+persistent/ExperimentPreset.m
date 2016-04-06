classdef ExperimentPreset < symphonyui.core.persistent.EntityPreset
    
    properties
        purpose
    end
    
    methods
        
        function obj = ExperimentPreset(name, descriptionType, propertyMap, purpose)
            entityType = symphonyui.core.persistent.EntityType.EXPERIMENT;
            obj@symphonyui.core.persistent.EntityPreset(name, entityType, descriptionType, propertyMap);
            obj.purpose = purpose;
        end
        
        function s = toStruct(obj)
            s = toStruct@symphonyui.core.persistent.EntityPreset(obj);
            s.purpose = obj.purpose;
        end
        
    end
    
    methods (Static)
        
        function obj = fromStruct(s)
            obj = symphonyui.core.persistent.ExperimentPreset(s.name, s.entityType, s.descriptionType, s.propertyMap, s.purpose);
        end
        
    end
    
end

