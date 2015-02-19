classdef SettingsBase < handle
    
    properties (Access = private)
        jpref
    end
    
    methods
        
        function obj = SettingsBase()
            node = strrep(class(obj), '.', '/');
            obj.jpref = java.util.prefs.Preferences.userRoot().node(node);
        end
        
        function reset(obj)
            obj.jpref.clear();
        end
        
    end
    
    methods (Access = protected)
        
        function v = get(obj, key, default)
            v = char(obj.jpref.get(key, default));
        end
        
        function put(obj, key, value)
            obj.jpref.put(key, value);
        end
        
    end
    
end
