classdef App < handle
    
    properties (Constant)
        displayName = 'Symphony'
        version = '2.0.0-preview'
        rootPath = fullfile(mfilename('fullpath'), '..', '..', '..')
        documentationUrl = 'https://github.com/Symphony-DAS/Symphony/wiki'
        userGroupUrl = 'https://groups.google.com/forum/#!forum/symphony-das'
    end
    
    properties (SetAccess = private)
        config
    end
    
    methods
        
        function obj = App(config)
            if nargin < 1
                config = symphonyui.app.Config();
            end
            obj.config = config;
        end
        
    end
    
end

