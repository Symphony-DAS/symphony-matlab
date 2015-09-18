classdef View < handle

    events
        KeyPress
        Close
    end

    properties
        position
    end

    properties (Access = protected)
        figureHandle
    end

    methods

        function obj = View()
            obj.figureHandle = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'HandleVisibility', 'off', ...
                'Visible', 'off', ...
                'DockControls', 'off', ...
                'Interruptible', 'off', ...
                'WindowKeyPressFcn', @(h,d)notify(obj, 'KeyPress', symphonyui.ui.UiEventData(d)), ...
                'CloseRequestFcn', @(h,d)notify(obj, 'Close'));

            if ispc
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            elseif ismac
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Helvetica Neue');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 12);
            end

            try
                obj.createUi();
            catch x
                delete(obj.figureHandle);
                rethrow(x);
            end
        end

        function delete(obj)
            obj.close();
        end

        function setWindowStyle(obj, s)
            set(obj.figureHandle, 'WindowStyle', s);
        end

        function show(obj)
            figure(obj.figureHandle);
        end

        function hide(obj)
            set(obj.figureHandle, 'Visible', 'off');
            obj.resume();
        end

        function close(obj)
            delete(obj.figureHandle);
        end

        function wait(obj)
            uiwait(obj.figureHandle);
        end

        function resume(obj)
            uiresume(obj.figureHandle);
        end

        function update(obj) %#ok<MANU>
            drawnow();
        end

        function showError(obj, msg)
            obj.showMessage(msg, 'Error');
        end

        function r = showMessage(obj, text, title, button1, button2, button3, default) %#ok<INUSL>
            if nargin < 3
                title = '';
            end
            if nargin < 4
                button1 = 'OK';
            end
            if nargin < 5
                button2 = [];
            end
            if nargin < 6
                button3 = [];
            end
            if nargin < 7
                default = 1;
            end
            presenter = symphonyui.ui.presenters.MessageBoxPresenter(text, title, button1, button2, button3, default);
            presenter.goWaitStop();
            r = presenter.result;
        end

        function showWeb(obj, url) %#ok<INUSL>
            web(url);
        end
        
        function p = showGetDirectory(obj, title, startPath) %#ok<INUSL>
            if nargin < 3
                startPath = pwd();
            end
            folderName = uigetdir(startPath, title);
            if folderName == 0
                p = [];
                return;
            end
            p = folderName;
        end

        function p = showGetFile(obj, title, filter, defaultName) %#ok<INUSL>
            if nargin < 3
                filter = '*';
            end
            if nargin < 4
                defaultName = '';
            end
            [filename, pathname] = uigetfile(filter, title, defaultName);
            if filename == 0
                p = [];
                return;
            end
            p = fullfile(pathname, filename);
        end

        function p = showPutFile(obj, title, filter, defaultName) %#ok<INUSL>
            if nargin < 3
                filter = '*';
            end
            if nargin < 4
                defaultName = '';
            end
            [filename, pathname] = uiputfile(filter, title, defaultName);
            if filename == 0
                p = [];
                return;
            end
            p = fullfile(pathname, filename);
        end

        function p = get.position(obj)
            p = get(obj.figureHandle, 'Position');
        end

        function set.position(obj, p)
            set(obj.figureHandle, 'Position', p); %#ok<MCSUP>
        end

    end

    methods (Abstract)
        createUi(obj);
    end

end
