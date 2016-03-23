classdef EntityNodeType
    
    enumeration
        SOURCES_FOLDER
        SOURCE
        EXPERIMENT
        EPOCH_GROUP_FOLDER
        EPOCH_GROUP
        EPOCH_BLOCK
        EPOCH
    end
    
    methods
        
        function c = char(obj)
            import symphonyui.ui.views.EntityNodeType;
            
            switch obj
                case EntityNodeType.SOURCES_FOLDER
                    c = 'Sources Folder';
                case EntityNodeType.SOURCE
                    c = 'Source';
                case EntityNodeType.EXPERIMENT
                    c = 'Experiment';
                case EntityNodeType.EPOCH_GROUP_FOLDER
                    c = 'Epoch Group Folder';
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
        
        function tf = isSourcesFolder(obj)
            tf = obj == symphonyui.ui.views.EntityNodeType.SOURCES_FOLDER;
        end
        
        function tf = isSource(obj)
            tf = obj == symphonyui.ui.views.EntityNodeType.SOURCE;
        end
        
        function tf = isExperiment(obj)
            tf = obj == symphonyui.ui.views.EntityNodeType.EXPERIMENT;
        end
        
        function tf = isEpochGroupFolder(obj)
            tf = obj == symphonyui.ui.views.EntityNodeType.EPOCH_GROUP_FOLDER;
        end
        
        function tf = isEpochGroup(obj)
            tf = obj == symphonyui.ui.views.EntityNodeType.EPOCH_GROUP;
        end
        
    end
    
end

