classdef DeviceSet < symphonyui.core.collections.EntitySet
    
    properties (SetAccess = private)
        name
        manufacturer
    end
    
    methods
        
        function obj = DeviceSet(devices)
            obj@symphonyui.core.collections.EntitySet(devices);
        end
        
        function n = get.name(obj)
            n = strjoin(unique(cellfun(@(d)d.name, obj.entities, 'UniformOutput', false)), ', ');
        end
        
        function m = get.manufacturer(obj)
            m = strjoin(unique(cellfun(@(d)d.manufacturer, obj.entities, 'UniformOutput', false)), ', ');
        end
        
    end
    
end

