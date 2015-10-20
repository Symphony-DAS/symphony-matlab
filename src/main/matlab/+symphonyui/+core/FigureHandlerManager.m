classdef FigureHandlerManager < handle
    
    properties (Access = private)
        log
        figureHandlers
    end
    
    methods
        
        function obj = FigureHandlerManager()
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.figureHandlers = {};
        end
        
        function delete(obj)
            obj.closeFigures();
        end
        
        function h = showFigure(obj, className, varargin)
            for i = 1:numel(obj.figureHandlers)
                handler = obj.figureHandlers{i};
                if strcmp(class(handler), className)
                    handler.show();
                    h = handler;
                    return;
                end
            end
            
            constructor = str2func(className);
            handler = constructor(varargin{:});
            handler.show();
            obj.figureHandlers{end + 1} = handler;
            addlistener(handler, 'Closed', @obj.onFigureHandlerClosed);
            h = handler;
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
        
        function clearFigures(obj)
            for i = 1:numel(obj.figureHandlers)
                obj.figureHandlers{i}.clear();
            end
        end
        
        function closeFigures(obj)
            while ~isempty(obj.figureHandlers)
                obj.figureHandlers{1}.close();
            end
        end
        
    end
    
    methods (Access = private)
        
        function onFigureHandlerClosed(obj, handler, ~)
            index = cellfun(@(h)h == handler, obj.figureHandlers);
            obj.figureHandlers(index) = [];
        end
        
    end
    
end

