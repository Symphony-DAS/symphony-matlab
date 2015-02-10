classdef ProtocolPreferences < handle
    
    properties (SetObservable, AbortSet)
        searchPaths
    end
    
    methods
        
        function setToDefaults(obj)
            import symphonyui.app.App;
            
            obj.searchPaths = { ...
                fullfile(fullfile(App.rootPath, 'examples', '+io', '+github', '+symphony_das', '+protocols'))};
        end
        
    end
    
end

