classdef (Abstract) Settings < handle
    
    properties
        settingsKey
    end
    
    properties (Access = private)
        settingsGroup
        settingsPreference
        instanceMap
    end
    
    methods
        
        function save(obj)
            settingsMap = getpref(obj.settingsGroup, obj.settingsPreference);
            settingsMap(obj.settingsKey) = obj.instanceMap;
            setpref(obj.settingsGroup, obj.settingsPreference, settingsMap);
        end
        
        function reset(obj)
            settingsMap = getpref(obj.settingsGroup, obj.settingsPreference);
            settingsMap(obj.settingsKey) = containers.Map();
            setpref(obj.settingsGroup, obj.settingsPreference, settingsMap);
            obj.instanceMap = settingsMap(obj.settingsKey);
        end
        
    end
    
    methods (Access = protected)
        
        function obj = Settings(settingsKey, settingsGroup)
            if nargin < 1
                settingsKey = matlab.lang.makeValidName(class(obj));
            end
            if nargin < 2
                settingsGroup = 'symphony';
            end
            obj.settingsGroup = settingsGroup;
            obj.settingsPreference = matlab.lang.makeValidName(class(obj));
            obj.settingsKey = settingsKey;
            settingsMap = getpref(obj.settingsGroup, obj.settingsPreference, containers.Map());
            if ~settingsMap.isKey(settingsKey)
                settingsMap(settingsKey) = containers.Map();
            end
            obj.instanceMap = settingsMap(settingsKey);
        end
        
        function tf = isKey(obj, key)
            tf = obj.instanceMap.isKey(key);
        end
        
        function v = get(obj, key, default)
            if nargin < 3
                default = [];
            end
            if obj.instanceMap.isKey(key)
                v = obj.instanceMap(key);
            else
                v = default;
            end
        end
        
        function put(obj, key, value)
            obj.instanceMap(key) = value;
        end
        
    end
    
end

