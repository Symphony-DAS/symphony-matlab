classdef FigureHandler < handle
    
    events (NotifyAccess = private)
        Closed
    end
    
    properties (Access = protected)
        figureHandle
        log
        settings
    end
    
    methods
        
        function obj = FigureHandler(settingsKey)
            if nargin < 1
                settingsKey = '';
            end
            obj.figureHandle = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'figure', ...
                'HandleVisibility', 'off', ...
                'Visible', 'off', ...
                'DockControls', 'off');
            if ispc
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            elseif ismac
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Helvetica Neue');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 12);
            end
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.core.FigureHandlerSettings([matlab.lang.makeValidName(class(obj)) '_' settingsKey]);
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load figure handler settings: ' x.message], x);
            end
        end
        
        function delete(obj)
            obj.close();
        end
        
        function show(obj)
            figure(obj.figureHandle);
            set(obj.figureHandle, 'CloseRequestFcn', @obj.onSelectedClose);
        end
        
        function clear(obj) %#ok<MANU>
            
        end
        
        function hide(obj)
            set(obj.figureHandle, 'Visible', 'off');
        end
        
        function close(obj)
            if ~isvalid(obj.figureHandle)
                return;
            end
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save figure handler settings: ' x.message], x);
            end
            delete(obj.figureHandle);
            notify(obj, 'Closed');
        end
        
        function loadSettings(obj)
            if ~isempty(obj.settings.figurePosition)
                set(obj.figureHandle, 'Position', obj.settings.figurePosition);
            end
        end
        
        function saveSettings(obj)
            obj.settings.figurePosition = get(obj.figureHandle, 'Position');
            obj.settings.save();
        end
        
    end
    
    methods (Access = protected)
        
        function onSelectedClose(obj, ~, ~)
            obj.close();
        end
        
    end
    
    methods (Abstract)
        handleEpoch(obj, epoch);
    end
    
end

