classdef Preset < handle
    
    properties (SetAccess = private)
        displayName
        className
        valueMap
        id
    end
    
    methods
        
        function obj = Preset(displayName, className, valueMap)
            obj.displayName = displayName;
            obj.className = className;
            obj.valueMap = valueMap;
            obj.id = char(java.util.UUID.randomUUID);
        end
        
        function apply(obj, object)
            if strcmp(class(object), obj.className)
                error(['This preset is for objects of class ''' obj.className '''']);
            end
            
            keys = obj.valueMap.keys;
            for i = 1:numel(keys)
                k = keys{i};
                object.(k) = obj.valueMap(k);
            end
        end
        
    end
    
    methods (Static)
        
        function obj = fromObject(displayName, object)
            map = containers.Map();
            
            clazz = metaclass(object);
            properties = clazz.Properties;
            for i = 1:numel(properties)
                p = properties{i};
                if p.Constant || p.Abstract || p.Hidden || ~strcmp(p.GetAccess, 'public')
                    continue;
                end
                map(p.name) = object.(p.name);
            end
            
            obj = symphonyui.models.Preset(displayName, class(object), map);
        end
        
    end
    
end

