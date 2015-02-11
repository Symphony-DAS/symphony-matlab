classdef Presets < handle
    
    properties (SetAccess = private)
        presetsMap
    end
    
    methods
        
        function obj = Presets()
            obj.presetsMap = containers.Map();
        end
        
        function addPreset(obj, className, preset)
            if ~obj.presetsMap.isKey(className)
                obj.presetsMap(className) = [];
            end
            
            value = obj.presetsMap(className);
            if any(arrayfun(@(p)strcmp(p.displayName, preset.displayName), value))
                error(['Preset named ''' preset.displayName ''' already exists']);
            end
            
            obj.presetsMap(className) = [value preset];
        end
        
        function p = getPreset(obj, className, displayName)
            if ~obj.presetsMap.isKey(className)
                error(['No presets for ' className]);
            end
            
            value = obj.presetsMap(className);
            index = arrayfun(@(p)strcmp(p.displayName, preset.displayName), value);
            if ~any(index)
                error(['No preset named ''' displayName '''']);
            end
            
            assert(numel(value(index) == 1));
            p = value(index);
        end
        
        function p = getAllPresets(obj, className)
            if ~obj.presetsMap.isKey(className)
                p = symphonyui.models.Preset.empty(0, 1);
                return;
            end
            p = obj.presetsMap(className);
        end
            
        function removePreset(obj, className, displayName)
            if ~obj.presetsMap.isKey(className)
                error(['No presets for ' className]);
            end
            
            value = obj.presetsMap(className);
            index = arrayfun(@(p)strcmp(p.displayName, preset.displayName), value);
            if ~any(index)
                error(['No preset named ''' displayName '''']);
            end
            
            assert(numel(value(index) == 1));
            value(index) = [];
            
            obj.presetsMap(className) = value;
        end
        
    end
    
end

