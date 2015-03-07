classdef RigRepository < symphonyui.app.repos.IdentifiableRepository & symphonyui.util.mixin.Observer
    
    properties (Access = private)
        config
    end
    
    methods
        
        function obj = RigRepository(config)
            obj = obj@symphonyui.app.repos.IdentifiableRepository('symphonyui.core.Rig');
            obj.config = config;
            obj.addListener(config, 'Changed', @obj.onChangedConfig);
            obj.init();
        end
        
    end
    
    methods (Access = private)
        
        function onChangedConfig(obj, ~, data)
            if ~strcmp(data.key, symphonyui.app.Settings.GENERAL_RIG_SEARCH_PATH)
                return;
            end
            obj.init();
        end
        
        function init(obj)
            obj.setSearchPaths(obj.config.get(symphonyui.app.Settings.GENERAL_RIG_SEARCH_PATH));
            obj.loadAll();
        end
        
    end
    
end

