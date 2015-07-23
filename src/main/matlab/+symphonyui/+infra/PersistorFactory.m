classdef PersistorFactory < handle
    
    methods
        
        function p = new(obj, name, location)
            path = fullfile(location, [name '.h5']);
            if exist(path, 'file')
                error('File exists');
            end
            p = symphonyui.core.Persistor(Symphony.Core.H5EpochPersistor.Create(path));
        end
        
        function p = open(obj, path)
            if ~exist(path, 'file')
                error('File does not exist');
            end
            p = symphonyui.core.Persistor(Symphony.Core.H5EpochPersistor(path));
        end
        
    end
    
end

