classdef Settings < handle
    
    properties (Constant)
        
        GENERAL_RIG_SEARCH_PATH = 'GENERAL_RIG_SEARCH_PATH'
        
        GENERAL_PROTOCOL_SEARCH_PATH = 'GENERAL_PROTOCOL_SEARCH_PATH'
        
        EXPERIMENT_DEFAULT_NAME = 'EXPERIMENT_DEFAULT_NAME'
        
        EXPERIMENT_DEFAULT_LOCATION = 'EXPERIMENT_DEFAULT_LOCATION'
        
    end
    
    methods (Static)
        
        function d = getDefault(setting)
            import symphonyui.app.Settings;
            
            switch setting
                case Settings.GENERAL_RIG_SEARCH_PATH
                    d = {fullfile(symphonyui.app.App.rootPath, 'examples', '+io', '+github', '+symphony_das', '+rigs')};
                case Settings.GENERAL_PROTOCOL_SEARCH_PATH
                    d = {fullfile(symphonyui.app.App.rootPath, 'examples', '+io', '+github', '+symphony_das', '+protocols')};
                case Settings.EXPERIMENT_DEFAULT_NAME
                    d = @()datestr(now, 'yyyy-mm-dd');
                case Settings.EXPERIMENT_DEFAULT_LOCATION
                    d = @()pwd();
                otherwise
                    error(['No default for setting ' setting]);
            end
        end
    end
    
end