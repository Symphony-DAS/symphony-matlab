classdef EntityType
    
    enumeration
        ENTITY
        SOURCE
        EXPERIMENT
        EPOCH_GROUP
        EPOCH_BLOCK
        EPOCH
    end
    
    methods
        
        function c = char(obj)
            import symphonyui.core.persistent.EntityType;
            
            switch obj
                case EntityType.ENTITY
                    c = 'Entity';
                case EntityType.SOURCE
                    c = 'Source';
                case EntityType.EXPERIMENT
                    c = 'Experiment';
                case EntityType.EPOCH_GROUP
                    c = 'Epoch Group';
                case EntityType.EPOCH_BLOCK
                    c = 'Epoch Block';
                case EntityType.EPOCH
                    c = 'Epoch';
                otherwise
                    c = 'Unknown';
            end
        end
        
    end
    
    methods (Static)
        
        function obj = fromChar(c)
            import symphonyui.core.persistent.EntityType;
            
            switch c
                case 'Entity'
                    obj = EntityType.ENTITY;
                case 'Source'
                    obj = EntityType.SOURCE;
                case 'Experiment'
                    obj = EntityType.EXPERIMENT;
                case 'Epoch Group'
                    obj = EntityType.EPOCH_GROUP;
                case 'Epoch Block'
                    obj = EntityType.EPOCH_BLOCK;
                case 'Epoch'
                    obj = EntityType.EPOCH;
                otherwise
                    error('Unknown type');
            end
        end
        
    end
    
end

