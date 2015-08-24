classdef EntityNodeType
    
    enumeration
        FOLDER
        SOURCE
        EXPERIMENT
        EPOCH_GROUP
        EPOCH_BLOCK
        EPOCH
    end
    
    methods
        
        function c = char(obj)
            import symphonyui.ui.views.EntityNodeType;
            
            switch obj
                case EntityNodeType.FOLDER
                    c = 'Folder';
                case EntityNodeType.SOURCE
                    c = 'Source';
                case EntityNodeType.EXPERIMENT
                    c = 'Experiment';
                case EntityNodeType.EPOCH_GROUP
                    c = 'Epoch Group';
                case EntityNodeType.EPOCH_BLOCK
                    c = 'Epoch Block';
                case EntityNodeType.EPOCH
                    c = 'Epoch';
                otherwise
                    c = 'Unknown';
            end
        end
        
    end
    
end

