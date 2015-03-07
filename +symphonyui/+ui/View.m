classdef View < symphonyui.util.mixin.Observer
    
    properties
        position
    end
    
    properties (SetAccess = private)
        isShown
    end
    
    properties (Access = protected)
        figureHandle
    end
    
    properties (Access = private)
        parent
    end
    
    events (NotifyAccess = private)
        Shown
        Closing
    end
    
    methods
        
        function obj = View(parent)            
            if nargin < 1
                parent = [];
            end
            obj.parent = parent;
            if ~isempty(parent)
                obj.addListener(parent, 'Closing', @(h,d)obj.close);
            end
            
            obj.figureHandle = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'HandleVisibility', 'off', ...
                'Visible', 'off', ...
                'DockControls', 'off', ...
                'CloseRequestFcn', @(h,d)obj.close());
            obj.isShown = false;
            
            if ispc
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            elseif ismac
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Helvetica Neue');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 12);
            end
            
            obj.createUI();
        end
        
        function show(obj)
            if ~isvalid(obj.figureHandle)
                error('View has been closed');
            end
            if obj.isShown
                error('View is already shown');
            end
            figure(obj.figureHandle);
            obj.isShown = true;
            notify(obj, 'Shown');
        end
        
        function activate(obj)
            if ~obj.isShown
                error('View must be shown before it can be activated');
            end
            figure(obj.figureHandle);
        end
        
        function update(obj)
            drawnow update;
        end
        
        function showDialog(obj)
            set(obj.figureHandle, 'WindowStyle', 'modal');
            obj.show();
            uiwait(obj.figureHandle);
        end
        
        function showError(obj, msg)
            view = symphonyui.ui.views.MessageBoxView(obj);
            presenter = symphonyui.ui.presenters.MessageBoxPresenter(msg, 'Error', view);
            presenter.view.position = symphonyui.util.screenCenter(450, 85);
            presenter.view.showDialog();
        end
        
        function showMessage(obj, msg, title)
            view = symphonyui.ui.views.MessageBoxView(obj);
            presenter = symphonyui.ui.presenters.MessageBoxPresenter(msg, title, view);
            presenter.view.position = symphonyui.util.screenCenter(450, 85);
            presenter.view.showDialog();
        end
        
        function close(obj)
            notify(obj, 'Closing');
            delete(obj.figureHandle);
            obj.removeAllListeners();
        end
        
        function tf = isClosed(obj)
            tf = ~isvalid(obj.figureHandle);
        end
        
        function p = get.position(obj)
            p = get(obj.figureHandle, 'Position');
        end
        
        function set.position(obj, p)
            set(obj.figureHandle, 'Position', p); %#ok<MCSUP>
        end
        
        function savePosition(obj)
            pref = [strrep(class(obj), '.', '_') '_Position'];
            setpref('symphonyui', pref, obj.position);
        end
        
        function loadPosition(obj)
            pref = [strrep(class(obj), '.', '_') '_Position'];
            if ispref('symphonyui', pref)
                obj.position = getpref('symphonyui', pref);
            end
        end
        
        function setWindowKeyPressFcn(obj, fcn)
            set(obj.figureHandle, 'WindowKeyPressFcn', fcn);
        end
        
        function clearUI(obj)
            clf(obj.figureHandle);
        end
        
        function f = getFigureHandle(obj)
            f = obj.figureHandle;
        end
        
    end
    
    methods (Abstract)
        createUI(obj);
    end
    
end

