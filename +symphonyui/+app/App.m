classdef App
    
    methods (Static)
        
        function p = rootPath()
            p = fullfile(fileparts(mfilename('fullpath')), '..', '..');
        end
        
        function v = version()
            v = '2.0.0-preview';
        end
        
    end
    
end

