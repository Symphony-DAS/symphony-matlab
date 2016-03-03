classdef App < handle
    
    methods (Static)
        
        function t = title()
            t = 'Symphony Data Acquisition System';
        end
        
        function v = version()
            v = '2.0.1.4'; % i.e. 2.0-b4
        end
        
        function c = copyright()
            c = [char(169) ' 2016 Symphony-DAS'];
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

