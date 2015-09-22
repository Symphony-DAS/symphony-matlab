classdef (Abstract) Settings < handle
    
    properties (Access = private)
        group
        settingsMap
    end
    
    methods
        
        function save(obj)
            setpref(obj.group, matlab.lang.makeValidName(class(obj)), obj.settingsMap);
        end
        
        function reset(obj)
            setpref(obj.group, matlab.lang.makeValidName(class(obj)), containers.Map());
            obj.settingsMap = containers.Map();
        end
        
    end
    
    methods (Access = protected)
        
        function obj = Settings(group)
            if nargin < 1
                group = 'symphony';
            end
            obj.group = group;
            obj.settingsMap = getpref(obj.group, matlab.lang.makeValidName(class(obj)), containers.Map());
        end
        
        function tf = isKey(obj, key)
            tf = obj.settingsMap.isKey(key);
        end
        
        function v = get(obj, key, default)
            if nargin < 3
                default = [];
            end
            if obj.settingsMap.isKey(key)
                v = obj.settingsMap(key);
            else
                v = default;
            end
        end
        
        function put(obj, key, value)
            obj.settingsMap(key) = value;
        end
        
    end
    
end

