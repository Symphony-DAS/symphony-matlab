classdef Config < handle
    
    properties (Access = private)
        defaults
    end
    
    properties (Constant, Access = private)
        GROUP = 'symphonyui';
    end
    
    methods
        
        function obj = Config()
            obj.defaults = containers.Map();
        end
        
        function setDefaults(obj, defaults)
            obj.defaults = defaults;
        end
        
        function v = get(obj, key)
            if ispref(obj.GROUP, key)
                v = getpref(obj.GROUP, key);
            else
                v = obj.defaults(key);
            end
        end
        
        function put(obj, key, value)
            if ispref(obj.GROUP, key)
                if isequal(getpref(obj.GROUP, key), value)
                    return;
                end
                setpref(obj.GROUP, key, value);
            else
                addpref(obj.GROUP, key, value);
            end
        end
        
    end
    
end
