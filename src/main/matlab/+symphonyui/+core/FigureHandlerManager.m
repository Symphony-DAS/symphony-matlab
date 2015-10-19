classdef FigureHandlerManager < handle
    
    properties (Access = private)
        log
        containers
    end
    
    methods
        
        function obj = FigureHandlerManager()
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.containers = {};
        end
        
        function delete(obj)
            obj.closeFigures();
        end
        
        function h = showFigure(obj, className, varargin)
            for i = 1:numel(obj.containers)
                c = obj.containers{i};
                if strcmp(class(c.handler), className) && isequal(c.varargin, varargin)
                    c.handler.show();
                    h = c.handler;
                    return;
                end
            end
            
            constructor = str2func(className);
            handler = constructor(varargin{:});
            handler.show();
            addlistener(handler, 'Closed', @obj.onFigureHandlerClosed);
            
            container.handler = handler;
            container.varargin = varargin;
            obj.containers{end + 1} = container;
            
            h = handler;
        end
        
        function updateFigures(obj, epoch)
            for i = 1:numel(obj.containers)
                try
                    obj.containers{i}.handler.handleEpoch(epoch);
                catch x
                    obj.log.warn(x.message, x);
                end
            end
        end
        
        function clearFigures(obj)
            for i = 1:numel(obj.containers)
                obj.containers{i}.handler.clear();
            end
        end
        
        function closeFigures(obj)
            while ~isempty(obj.containers)
                obj.containers{1}.handler.close();
            end
        end
        
    end
    
    methods (Access = private)
        
        function onFigureHandlerClosed(obj, handler, ~)
            index = cellfun(@(c)c.handler == handler, obj.containers);
            obj.containers(index) = [];
        end
        
    end
    
end

