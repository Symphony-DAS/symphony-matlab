classdef App < handle

    methods (Static)

        function t = title()
            t = 'Symphony Data Acquisition System';
        end

        function v = version()
            v = '2.0.3.0'; % i.e. 2.0-r
        end

        function c = copyright()
            c = [char(169) ' 2016 Symphony-DAS'];
        end

        function u = documentationUrl()
            u = symphonyui.app.App.getResource('docs', 'Home.html');
        end

        function u = userGroupUrl()
            u = 'https://groups.google.com/forum/#!forum/symphony-das';
        end

        function p = getResource(varargin)
            resourcesPath = fullfile(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))), 'resources');
            p = fullfile(resourcesPath, varargin{:});
        end

    end

end
