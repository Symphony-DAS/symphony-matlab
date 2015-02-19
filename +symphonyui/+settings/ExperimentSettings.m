classdef ExperimentSettings < symphonyui.SettingsBase
    
    properties (SetObservable, AbortSet)
        defaultName
        defaultPurpose
        defaultLocation
    end
    
    properties (Constant, Access = private)
        DEFAULT_NAME_KEY = 'DEFAULT_NAME';
        DEFAULT_PURPOSE_KEY = 'DEFAULT_PURPOSE';
        DEFAULT_LOCATION_KEY = 'DEFAULT_LOCATION';
    end
    
    methods
        
        function n = get.defaultName(obj)
            n = obj.get(obj.DEFAULT_NAME_KEY, '@()datestr(now, ''yyyy-mm-dd'')');
        end
        
        function set.defaultName(obj, n)
            obj.put(obj.DEFAULT_NAME_KEY, n);
        end
        
        function p = get.defaultPurpose(obj)
            p = obj.get(obj.DEFAULT_PURPOSE_KEY, '');
        end
        
        function l = get.defaultLocation(obj)
            l = obj.get(obj.DEFAULT_LOCATION_KEY, '@()pwd');
        end
        
    end
    
end

