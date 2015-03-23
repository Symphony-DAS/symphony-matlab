classdef Config < handle
    
    properties (Constant, Access = private)
        GROUP = 'symphonyui'
    end
    
    properties (Access = private)
        defaults
    end
    
    methods
        
        function obj = Config()
            obj.defaults = containers.Map();
        end
        
        function setDefaults(obj, defaults)
            obj.defaults = defaults;
        end
        
        function v = get(obj, key)
            if ispref(symphonyui.infra.Config.GROUP, key)
                v = getpref(symphonyui.infra.Config.GROUP, key);
            else
                v = obj.defaults(key);
            end
        end
        
        function put(obj, key, value) %#ok<INUSL>
            if ispref(symphonyui.app.Config.GROUP, key)
                if isequal(getpref(symphonyui.infra.Config.GROUP, key), value)
                    return;
                end
                setpref(symphonyui.infra.Config.GROUP, key, value);
            else
                addpref(symphonyui.infra.Config.GROUP, key, value);
            end
        end
        
        function clear(obj) %#ok<MANU>
            rmpref(symphonyui.infra.Config.GROUP);
        end
        
    end
    
end
