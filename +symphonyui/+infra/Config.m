classdef Config < handle
    
    properties (Access = private)
        group
        defaults
    end
    
    methods
        
        function obj = Config(group)
            if nargin < 1
                group = 'symphonyui';
            end
            obj.group = group;
            obj.defaults = containers.Map();
        end
        
        function setDefaults(obj, defaults)
            obj.defaults = defaults;
        end
        
        function v = get(obj, key)
            if ispref(obj.group, key)
                v = getpref(obj.group, key);
            else
                v = obj.defaults(key);
            end
        end
        
        function put(obj, key, value)
            if ispref(obj.group, key)
                if isequal(getpref(obj.group, key), value)
                    return;
                end
                setpref(obj.group, key, value);
            else
                addpref(obj.group, key, value);
            end
        end
        
        function clear(obj)
            rmpref(obj.group);
        end
        
    end
    
end
