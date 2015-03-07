classdef Config < handle
    
    events (NotifyAccess = private)
        Changed
    end
    
    properties (Constant, Access = private)
        group = 'symphonyui'
    end
    
    methods
        
        function v = get(obj, key, default)
            if nargin < 3
                default = symphonyui.app.Settings.getDefault(key);
            end
            v = getpref(obj.group, key, default);
            
            if isa(v, 'function_handle')
                obj.put(key, v);
            elseif ischar(v) && ~isempty(v) && v(1) == '@'
                v = str2func(v);
            end
        end
        
        function put(obj, key, value)
            % Function handles do not persist well.
            if isa(value, 'function_handle')
                value = func2str(value);
            end
            
            if ispref(obj.group, key)
                if isequal(getpref(obj.group, key), value)
                    return;
                end
                setpref(obj.group, key, value);
            else
                addpref(obj.group, key, value);
            end
            
            notify(obj, 'Changed', symphonyui.app.ConfigEventData(key));
        end
        
        function clear(obj)
            rmpref(obj.group);
        end
        
    end
    
end
