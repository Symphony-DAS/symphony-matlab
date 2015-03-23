classdef Settings < handle
    
    properties (Constant)
        
        GENERAL_RIG_SEARCH_PATH = 'GENERAL_RIG_SEARCH_PATH'
        
        GENERAL_PROTOCOL_SEARCH_PATH = 'GENERAL_PROTOCOL_SEARCH_PATH'
        
        EXPERIMENT_DEFAULT_NAME = 'EXPERIMENT_DEFAULT_NAME'
        
        EXPERIMENT_DEFAULT_LOCATION = 'EXPERIMENT_DEFAULT_LOCATION'
        
        EPOCH_GROUP_LABEL_LIST = 'EPOCH_GROUP_LABEL_LIST'
        
        SOURCE_LABEL_LIST = 'SOURCE_LABEL_LIST'
        
    end
    
    methods (Static)
        
        function d = getDefault(setting)
            import symphonyui.app.Settings;
            
            switch setting
                case Settings.GENERAL_RIG_SEARCH_PATH
                    d = {fullfile(symphonyui.app.App.getRootPath(), 'examples', '+io', '+github', '+symphony_das', '+rigs')};
                case Settings.GENERAL_PROTOCOL_SEARCH_PATH
                    d = {fullfile(symphonyui.app.App.getRootPath(), 'examples', '+io', '+github', '+symphony_das', '+protocols')};
                case Settings.EXPERIMENT_DEFAULT_NAME
                    d = @()datestr(now, 'yyyy-mm-dd');
                case Settings.EXPERIMENT_DEFAULT_LOCATION
                    d = @()pwd();
                case Settings.EPOCH_GROUP_LABEL_LIST
                    d = {'Control', 'Drug', 'Wash'};
                case Settings.SOURCE_LABEL_LIST
                    d = {'Animal', 'Tissue', 'Cell'};
                otherwise
                    error(['No default for setting ' setting]);
            end
        end
    end
    
end