classdef App < handle
    
    methods (Static)
        
        function t = title()
            t = 'Symphony Data Acquisition System';
        end
        
        function v = version()
            v = '2.0.0-preview';
        end
        
        function c = copyright()
            c = [char(169) ' 2015 Symphony-DAS'];
        end
        
        function u = documentationUrl()
            u = 'https://github.com/Symphony-DAS/Symphony/wiki';
        end
        
        function u = userGroupUrl()
            u = 'https://groups.google.com/forum/#!forum/symphony-das';
        end
        
        function p = getResource(name)
            resourcesPath = fullfile(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))), 'resources');
            p = fullfile(resourcesPath, name);
        end
        
    end
    
end

