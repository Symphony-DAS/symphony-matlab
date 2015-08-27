classdef FigureHandler < handle
    
    events (NotifyAccess = private)
        Closed
    end
    
    properties (Access = protected)
        figureHandle
    end
    
    methods
        
        function obj = FigureHandler()
            obj.figureHandle = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'figure', ...
                'HandleVisibility', 'off', ...
                'Visible', 'off', ...
                'DockControls', 'off', ...
                'CloseRequestFcn', @obj.onClose);

            if ispc
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            elseif ismac
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Helvetica Neue');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 12);
            end
        end
        
        function delete(obj)
            if isvalid(obj.figureHandle)
                obj.close();
            end
        end
        
        function show(obj)
            figure(obj.figureHandle);
        end
        
        function hide(obj)
            set(obj.figureHandle, 'Visible', 'off');
        end
        
        function close(obj)
            delete(obj.figureHandle);
            notify(obj, 'Closed');
        end
        
    end
    
    methods (Access = protected)
        
        function onClose(obj, ~, ~)
            obj.close();
        end
        
    end
    
    methods (Abstract)
        handleEpoch(obj, epoch);
    end
    
end

