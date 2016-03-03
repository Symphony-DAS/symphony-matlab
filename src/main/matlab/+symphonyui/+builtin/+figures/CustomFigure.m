classdef CustomFigure < symphonyui.core.FigureHandler
    
    properties
        userData
    end
    
    properties (SetAccess = private)
        handleEpochCallback
        clearCallback
    end
    
    methods
        
        function obj = CustomFigure(handleEpochCallback, varargin)
            ip = inputParser();
            ip.addParameter('clearCallback', @(h)[], @(x)isa(x, 'function_handle'));
            ip.parse(varargin{:});
            
            obj.handleEpochCallback = handleEpochCallback;
            obj.clearCallback = ip.Results.clearCallback;
            
            set(obj.figureHandle, 'Name', 'Custom Figure');
        end
        
        function h = getFigureHandle(obj)
            h = obj.figureHandle;
        end
        
        function clear(obj)
            obj.clearCallback(obj);
        end
        
        function handleEpoch(obj, epoch)
            obj.handleEpochCallback(obj, epoch);
        end
        
    end
        
end

