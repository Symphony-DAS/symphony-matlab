classdef PersistorFactory < handle
    
    methods
        
        function p = getPath(obj, name, location) %#ok<INUSL>
            p = fullfile(location, name);
            [~, ~, ext] = fileparts(p);
            if ~strcmpi(ext, '.h5')
                p = [p '.h5'];
            end
        end
        
        function p = new(obj, name, location, description)
            if ~exist(location, 'dir')
                error('Location does not exist');
            end
            path = obj.getPath(name, location);
            if exist(path, 'file')
                error('File exists');
            end
            cper = Symphony.Core.H5EpochPersistor.Create(path);
            try
                p = symphonyui.core.Persistor.newPersistor(cper, description);
            catch x
                cper.Close();
                rethrow(x);
            end
        end
        
        function p = open(obj, path) %#ok<INUSL>
            if ~exist(path, 'file')
                error('File does not exist');
            end
            p = symphonyui.core.Persistor(Symphony.Core.H5EpochPersistor(path));
        end
        
    end
    
end

