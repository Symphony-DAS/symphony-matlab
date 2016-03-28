classdef Presets < appbox.Settings
    
    properties
        protocolPresets
    end
    
    methods
        
        function p = get.protocolPresets(obj)
            p = obj.get('protocolPresets', containers.Map);
        end
        
        function set.protocolPresets(obj, p)
            validateattributes(p, {'containers.Map'}, {'2d'});
            obj.put('protocolPresets', p);
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

