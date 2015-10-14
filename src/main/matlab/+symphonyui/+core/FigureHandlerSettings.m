classdef FigureHandlerSettings < symphonyui.infra.Settings
    
    properties
        figurePosition
    end
    
    methods
        
        function obj = FigureHandlerSettings(settingsKey)
            obj@symphonyui.infra.Settings(settingsKey);
        end
        
        function p = get.figurePosition(obj)
            p = obj.get('figurePosition');
        end
        
        function set.figurePosition(obj, p)
            validateattributes(p, {'double'}, {'vector'});
            obj.put('figurePosition', p);
        end
        
    end
    
end

