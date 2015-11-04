classdef FigureView < appbox.View
    
    methods
        
        function createUi(obj) %#ok<MANU>
            % Do nothing.
        end
        
        function h = getFigureHandle(obj)
            h = obj.figureHandle;
        end
        
    end
    
end

