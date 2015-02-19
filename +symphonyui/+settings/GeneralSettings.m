classdef GeneralSettings < symphonyui.SettingsBase
    
    properties (SetObservable, AbortSet)
        rigSearchPaths
        protocolSearchPaths
    end
    
    properties (Constant, Access = private)
        RIG_SEARCH_PATHS_KEY = 'RIG_SEARCH_PATHS';
        PROTOCOL_SEARCH_PATHS_KEY = 'PROTOCOL_SEARCH_PATHS';
    end
    
    methods
        
        function p = get.rigSearchPaths(obj)
            p = obj.get(obj.RIG_SEARCH_PATHS_KEY, fullfile(examplesPath, '+rigs'));
        end
        
        function p = get.protocolSearchPaths(obj)
            p = obj.get(obj.PROTOCOL_SEARCH_PATHS_KEY, fullfile(examplesPath, '+protocols'));
        end
        
    end
    
end

function p = examplesPath()
    import symphonyui.app.App; 
    p = fullfile(App.rootPath, 'examples', '+io', '+github', '+symphony_das');
end