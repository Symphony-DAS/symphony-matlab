classdef Presets < appbox.Settings
    
    properties
        protocolPresets
    end
    
    methods
        
        function p = get.protocolPresets(obj)
            p = containers.Map();
            structs = obj.get('protocolPresets', containers.Map);
            keys = structs.keys;
            for i = 1:numel(keys)
                p(keys{i}) = symphonyui.core.ProtocolPreset.fromStruct(structs(keys{i}));
            end
        end
        
        function set.protocolPresets(obj, p)
            validateattributes(p, {'containers.Map'}, {'2d'});
            structs = containers.Map();
            keys = p.keys;
            for i = 1:numel(keys)
                preset = p(keys{i});
                structs(keys{i}) = preset.toStruct();
            end
            obj.put('protocolPresets', structs);
        end
        
    end
    
    methods (Static)
        
        function o = getDefault()
            persistent default;
            if isempty(default) || ~isvalid(default)
                default = symphonyui.app.Presets();
            end
            o = default;
        end
        
    end
    
end

