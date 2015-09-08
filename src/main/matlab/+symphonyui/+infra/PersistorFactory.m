classdef PersistorFactory < handle
    
    methods
        
        function p = getPath(obj, name, location)
            p = fullfile(location, name);
            [~, ~, ext] = fileparts(p);
            if ~strcmpi(ext, '.h5')
                p = [p '.h5'];
            end
        end
        
        function p = new(obj, name, location, description)
            path = obj.getPath(name, location);
            if exist(path, 'file')
                error('File exists');
            end
            cper = Symphony.Core.H5EpochPersistor.Create(path);
            p = symphonyui.core.Persistor.newPersistor(cper, description);
        end
        
        function p = open(obj, path)
            if ~exist(path, 'file')
                error('File does not exist');
            end
            p = symphonyui.core.Persistor(Symphony.Core.H5EpochPersistor(path));
        end
        
    end
    
end

