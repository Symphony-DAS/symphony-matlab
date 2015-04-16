classdef BiMap < handle
    
    properties (SetAccess = private)
        keys
        values
    end
    
    properties (Access = private)
        map
        inverse
    end
    
    methods
        
        function obj = BiMap()
            obj.map = containers.Map('KeyType', 'char', 'ValueType', 'char');
            obj.inverse = containers.Map('KeyType', obj.map.ValueType, 'ValueType', obj.map.KeyType);
        end
        
        function k = get.keys(obj)
            k = obj.map.keys;
        end
        
        function v = get.values(obj)
            v = obj.map.values;
        end
        
        function v = get(obj, key)
            v = obj.map(key);
        end
        
        function k = getKey(obj, value)
            k = obj.inverse(value);
        end
        
        function put(obj, key, value)
            obj.map(key) = value;
            obj.inverse(value) = key;
        end
        
        function clear(obj)
            obj.map = containers.Map('KeyType', obj.map.KeyType, 'ValueType', obj.map.ValueType);
            obj.inverse = containers.Map('KeyType', obj.map.ValueType, 'ValueType', obj.map.KeyType);
        end
        
    end
    
end

