classdef Presets < appbox.Settings
    
    properties (SetAccess = private)
        protocolPresets
        entityPresets
    end
    
    methods
        
        function addProtocolPreset(obj, preset)
            presets = obj.protocolPresets;
            if presets.isKey(preset.name)
                error([preset.name ' is already a protocol preset']);
            end
            presets(preset.name) = preset;
            obj.protocolPresets = presets;
        end
        
        function removeProtocolPreset(obj, name)
            presets = obj.protocolPresets;
            if ~presets.isKey(name)
                error([name ' is not an available protocol preset']);
            end
            presets.remove(name);
            obj.protocolPresets = presets;
        end
        
        function p = getProtocolPreset(obj, name)
            presets = obj.protocolPresets;
            if ~presets.isKey(name)
                error([name ' is not an available protocol preset']);
            end
            p = presets(name);
        end
        
        function n = getAvailableProtocolPresetNames(obj)
            presets = obj.protocolPresets;
            n = presets.keys;
        end
        
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
        
        function addEntityPreset(obj, preset)
            presets = obj.entityPresets;
            key = [char(preset.entityType) ':' char(preset.descriptionType) ':' preset.name];
            if presets.isKey(key)
                error([preset.name ' is already an entity preset']);
            end
            presets(key) = preset;
            obj.entityPresets = presets;
        end
        
        function removeEntityPreset(obj, name, entityType, descriptionType)
            presets = obj.entityPresets;
            key = [char(entityType) ':' char(descriptionType) ':' name];
            if ~presets.isKey(key)
                error([name ' is not an available entity preset']);
            end
            presets.remove(key);
            obj.entityPresets = presets;
        end
        
        function p = getEntityPreset(obj, name, entityType, descriptionType)
            presets = obj.entityPresets;
            key = [char(entityType) ':' char(descriptionType) ':' name];
            if ~presets.isKey(key)
                error([name ' is not an available entity preset']);
            end
            p = presets(key);
        end
        
        function n = getAvailableEntityPresetNames(obj, entityType, descriptionType)
            n = {};
            presets = obj.entityPresets;
            prefix = [char(entityType) ':' char(descriptionType) ':'];
            keys = presets.keys;
            for i = 1:numel(keys)
                key = keys{i};
                if strncmp(prefix, key, length(prefix))
                    n{end + 1} = key(length(prefix)+1:end); %#ok<AGROW>
                end
            end
        end
        
        function p = get.entityPresets(obj)
            p = containers.Map();
            structs = obj.get('entityPresets', containers.Map);
            keys = structs.keys;
            for i = 1:numel(keys)
                s = structs(keys{i});
                s.entityType = symphonyui.core.persistent.EntityType.fromChar(s.entityType);
                p(keys{i}) = symphonyui.core.persistent.EntityPreset.fromStruct(s);
            end
        end
        
        function set.entityPresets(obj, p)
            validateattributes(p, {'containers.Map'}, {'2d'});
            structs = containers.Map();
            keys = p.keys;
            for i = 1:numel(keys)
                preset = p(keys{i});
                s = preset.toStruct();
                s.entityType = char(s.entityType);
                structs(keys{i}) = s;
            end
            obj.put('entityPresets', structs);
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

