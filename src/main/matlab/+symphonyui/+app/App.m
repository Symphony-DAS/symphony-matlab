classdef App < handle
    
    properties (SetAccess = private)
        config
    end
    
    methods
        
        function obj = App(config)
            if nargin < 1
                config = symphonyui.infra.Config();
            end
            obj.config = config;
        end
        
    end
    
    methods (Static)
        
        function v = getVersion()
            v = '2.0.0-preview';
        end
        
        function p = getResource(name)
            resourcesPath = fullfile(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))), 'resources');
            p = fullfile(resourcesPath, name);
        end
        
        function url = getDocumentationUrl()
            url = 'https://github.com/Symphony-DAS/Symphony/wiki';
        end
        
        function url = getUserGroupUrl()
            url = 'https://groups.google.com/forum/#!forum/symphony-das';
        end
        
    end
    
end

