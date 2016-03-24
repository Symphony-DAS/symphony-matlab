classdef ProtocolPresetsView < appbox.View
    
    properties (Access = private)
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Protocol Presets', ...
                'Position', screenCenter(230, 300));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);
        end
        
    end
    
end

