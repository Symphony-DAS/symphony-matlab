classdef FigureHandlerManager < handle
    
    properties
        figureHandlers
    end
    
    methods
        
        function obj = FigureHandlerManager()
            obj.figureHandlers = {};
        end
        
        function delete(obj)
            obj.closeFigures();
        end
        
        function openFigure(obj, handler)
            index = cellfun(@(h)isequal(h, handler), obj.figureHandlers);
            if any(index)
                handler = obj.figureHandlers{index};
                handler.show();
                return;
            end
            handler.show();
            addlistener(handler, 'Closed', @obj.onFigureHandlerClosed);
            obj.figureHandlers{end + 1} = handler;
        end
        
        function updateFigures(obj, epoch)
            for i = 1:numel(obj.figureHandlers)
                try
                    obj.figureHandlers{i}.handleEpoch(epoch);
                catch x
                    obj.log.warn(x.message, x);
                end
            end
        end
        
        function closeFigures(obj)
            while ~isempty(obj.figureHandlers)
                obj.figureHandlers{1}.close();
            end
        end
        
        function onFigureHandlerClosed(obj, handler, ~)
            index = cellfun(@(h)isequal(h, handler), obj.figureHandlers);
            obj.figureHandlers(index) = [];
        end
        
    end
    
end

