classdef PresetService < handle
    
    properties (Access = private)
        repository
    end
    
    methods
        
        function obj = PresetService()
            obj.repository = containers.Map();
        end
        
        function add(obj, preset)            
            obj.respository(preset.id) = preset;
        end
        
        function remove(obj, id)
            obj.respository.remove(id);
        end
        
        function p = getAllByClass(obj, className)
            p = symphonyui.models.Preset.empty(0, 1);
            values = obj.repository.values;
            for i = 1:numel(values)
                v = values{i};
                if strcmp(v.className, className)
                    p = [p v];
                end
            end
        end
        
    end
    
end

