classdef FigureHandler < handle
    % A FigureHandler manages a figure displayed by a protocol. It creates the figure controls (typically a plot) and 
    % updates the figure as each epoch completes. A FigureHandler is generally used to graphically present data and 
    % perform online analysis.
    %
    % To write a new handler:
    %   1. Subclass FigureHandler
    %   2. Implement a constructor method to build the figure ui
    %   3. Implement the handleEpoch method to update the figure when epochs complete
    
    events (NotifyAccess = private)
        Closed  % Triggers when the handler is closed
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
        
        function handleEpoch(obj, epoch) %#ok<INUSD>
            
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
    
end

