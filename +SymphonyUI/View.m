classdef View < handle
    
    properties
        figureHandle
        position
        presenter
    end
    
    methods
        
        function obj = View(presenter)
            obj.presenter = presenter;
            obj.presenter.view = obj;
            
            obj.figureHandle = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'HandleVisibility', 'off', ...
                'Visible', 'off', ...
                'DockControls', 'off', ...
                'CloseRequestFcn', @presenter.onSelectedClose);
            
            if ispc
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            elseif ismac
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Helvetica Neue');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 12);
            end
            
            obj.createInterface();
            
            obj.presenter.viewDidLoad();
        end
        
        function show(obj)
            figure(obj.figureHandle);
        end
        
        function hide(obj)
            set(obj.figureHandle, 'Visible', 'off');
        end
        
        function close(obj)            
            delete(obj.figureHandle);
        end
        
        function tf = isClosed(obj)
            tf = ~isvalid(obj.figureHandle);
        end
        
        function centerOnScreen(obj, w, h)
            s = get(0, 'ScreenSize');
            sw = s(3);
            sh = s(4);
            x = (sw - w) / 2;
            y = (sh - h) / 2;
            set(obj.figureHandle, 'Position', [x y w h]);
        end
        
        function p = get.position(obj)
            p = get(obj.figureHandle, 'Position');
        end
        
        function set.position(obj, p)
            set(obj.figureHandle, 'Position', p); %#ok<MCSUP>
        end
        
    end
    
    methods (Abstract)
        createInterface(obj);
    end
    
end

