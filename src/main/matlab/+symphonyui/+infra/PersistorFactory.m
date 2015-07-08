classdef PersistorFactory < handle
    
    methods
        
        function p = create(obj, name, location)
            path = fullfile(location, [name '.h5']);
            p = symphonyui.core.Persistor(Symphony.Core.H5EpochPersistor.Create(path, 'my purpose here'));
        end
        
        function p = load(obj, path)
            p = symphonyui.core.Persistor(Symphony.Core.H5EpochPersistor(path));
        end
        
    end
    
end

