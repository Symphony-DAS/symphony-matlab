classdef MainView < appbox.View

    events
        NewFile
        OpenFile
        CloseFile
        Exit
        AddSource
        BeginEpochGroup
        SelectedProtocol
        SetProtocolProperty
        MinimizeProtocolPreview
        ViewOnly
        Record
        Pause
        Stop
        InitializeRig
        ConfigureDevices
        ConfigureOptions
        SelectedModule
        ShowDocumentation
        ShowUserGroup
        ShowAbout
    end

    properties (Access = private)
        fileMenu
        documentMenu
        acquireMenu
        configureMenu
        modulesMenu
        helpMenu
        protocolLayout
        protocolPopupMenu
        protocolPropertyGrid
        protocolPreviewBox
        protocolPreviewPanel
        viewOnlyButton
        recordButton
        pauseButton
        stopButton
    end

    methods

        function createUi(obj)
            import appbox.*;
            import symphonyui.app.App;

            set(obj.figureHandle, ...
                'Name', 'Symphony', ...
            	'Position', screenCenter(360, 340));

            % File menu.
            obj.fileMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'File');
            obj.fileMenu.newFile = uimenu(obj.fileMenu.root, ...
                'Label', 'New...', ...
                'Accelerator', 'N', ...
                'Callback', @(h,d)notify(obj, 'NewFile'));
            obj.fileMenu.openFile = uimenu(obj.fileMenu.root, ...
                'Label', 'Open...', ...
                'Accelerator', 'O', ...
                'Callback', @(h,d)notify(obj, 'OpenFile'));
            obj.fileMenu.closeFile = uimenu(obj.fileMenu.root, ...
                'Label', 'Close', ...
                'Callback', @(h,d)notify(obj, 'CloseFile'));
            obj.fileMenu.exit = uimenu(obj.fileMenu.root, ...
                'Label', 'Exit', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'Exit'));

            % Document menu.
            obj.documentMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Document');
            obj.documentMenu.addSource = uimenu(obj.documentMenu.root, ...
                'Label', 'Add Source...', ...
                'Callback', @(h,d)notify(obj, 'AddSource'));
            obj.documentMenu.beginEpochGroup = uimenu(obj.documentMenu.root, ...
                'Label', 'Begin Epoch Group...', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));

            % Acquire menu.
            obj.acquireMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Acquire');
            obj.acquireMenu.viewOnly = uimenu(obj.acquireMenu.root, ...
                'Label', 'View Only', ...
                'Accelerator', 'V', ...
                'Callback', @(h,d)notify(obj, 'ViewOnly'));
            obj.acquireMenu.record = uimenu(obj.acquireMenu.root, ...
                'Label', 'Record', ...
                'Accelerator', 'R', ...
                'Callback', @(h,d)notify(obj, 'Record'));
            obj.acquireMenu.pause = uimenu(obj.acquireMenu.root, ...
                'Label', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.acquireMenu.stop = uimenu(obj.acquireMenu.root, ...
                'Label', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));

            % Configure menu.
            obj.configureMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Configure');
            obj.configureMenu.initializeRig = uimenu(obj.configureMenu.root, ...
                'Label', 'Initialize Rig...', ...
                'Callback', @(h,d)notify(obj, 'InitializeRig'));
            obj.configureMenu.configureDevices = uimenu(obj.configureMenu.root, ...
                'Label', 'Devices...', ...
                'Accelerator', 'D', ...
                'Callback', @(h,d)notify(obj, 'ConfigureDevices'));
            obj.configureMenu.configureOptions = uimenu(obj.configureMenu.root, ...
                'Label', 'Options...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'ConfigureOptions'));

            % Modules menu.
            obj.modulesMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Modules');

            % Help menu.
            obj.helpMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Help');
            obj.helpMenu.showDocumentation = uimenu(obj.helpMenu.root, ...
                'Label', 'Documentation', ...
                'Callback', @(h,d)notify(obj, 'ShowDocumentation'));
            obj.helpMenu.showUserGroup = uimenu(obj.helpMenu.root, ...
                'Label', 'User Group', ...
                'Callback', @(h,d)notify(obj, 'ShowUserGroup'));
            obj.helpMenu.showAbout = uimenu(obj.helpMenu.root, ...
                'Label', 'About Symphony', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'ShowAbout'));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 9, ...
                'Spacing', 1);

            obj.protocolLayout = uix.VBoxFlex( ...
                'Parent', mainLayout, ...
                'DividerMarkings', 'off', ...
                'Padding', 1, ...
                'Spacing', 3);

            % TODO: Disable VBoxFlex divider

            protocolInputLayout = uix.VBox( ...
                'Parent', obj.protocolLayout, ...
                'Padding', 1, ...
                'Spacing', 5);

            obj.protocolPopupMenu = MappedPopupMenu( ...
                'Parent', protocolInputLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SelectedProtocol'));

            obj.protocolPropertyGrid = uiextras.jide.PropertyGrid(protocolInputLayout, ...
                'Callback', @(h,d)notify(obj, 'SetProtocolProperty', d), ...
                'ShowDescription', true);

            set(protocolInputLayout, 'Heights', [23 -1]);

            protocolPreviewLayout = uix.VBox( ...
                'Parent', obj.protocolLayout, ...
                'Padding', 1, ...
                'Spacing', 3);

            obj.protocolPreviewBox = uix.BoxPanel( ...
                'Parent', protocolPreviewLayout, ...
                'Title', 'Preview', ...
                'ForegroundColor', 'black', ...
                'TitleColor', [240/255, 240/255, 240/255], ...
                'BorderType', 'line', ...
                'HighlightColor', [160/255 160/255 160/255], ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'Minimized', true, ...
                'MinimizeFcn', @(h,d)notify(obj, 'MinimizeProtocolPreview'));

            obj.protocolPreviewPanel = uipanel( ...
                'Parent', obj.protocolPreviewBox, ...
                'BackgroundColor', 'white', ...
                'BorderType', 'none', ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));

            set(obj.protocolLayout, ...
                'Heights', [-1 21], ...
                'MinimumHeights', [23 21]);

            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Padding', 1, ...
                'Spacing', 0);

            path2Url = @(path)strrep(['file:/' path '/'],'\','/');

            obj.viewOnlyButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' path2Url(App.getResource('icons/view_only_big.png')) '"/></html>'], ...
                'TooltipString', 'View Only', ...
                'Callback', @(h,d)notify(obj, 'ViewOnly'));
            obj.recordButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' path2Url(App.getResource('icons/record_big.png')) '"/></html>'], ...
                'TooltipString', 'Record', ...
                'Callback', @(h,d)notify(obj, 'Record'));
            obj.pauseButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' path2Url(App.getResource('icons/pause_big.png')) '"/></html>'], ...
                'TooltipString', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.stopButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' path2Url(App.getResource('icons/stop_big.png')) '"/></html>'], ...
                'TooltipString', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));

            set(mainLayout, 'Heights', [-1 34]);
        end

        function close(obj)
            close@appbox.View(obj);
            obj.protocolPropertyGrid.Close();
        end

        function h = getViewHeight(obj)
            p = get(obj.figureHandle, 'Position');
            h = p(4);
        end

        function setViewHeight(obj, h)
            p = get(obj.figureHandle, 'Position');
            delta = p(4) - h;
            set(obj.figureHandle, 'Position', p + [0 delta 0 -delta]);
        end

        function enableNewFile(obj, tf)
            set(obj.fileMenu.newFile, 'Enable', appbox.onOff(tf));
        end

        function enableOpenFile(obj, tf)
            set(obj.fileMenu.openFile, 'Enable', appbox.onOff(tf));
        end

        function enableCloseFile(obj, tf)
            set(obj.fileMenu.closeFile, 'Enable', appbox.onOff(tf));
        end

        function enableAddSource(obj, tf)
            set(obj.documentMenu.addSource, 'Enable', appbox.onOff(tf));
        end

        function enableBeginEpochGroup(obj, tf)
            set(obj.documentMenu.beginEpochGroup, 'Enable', appbox.onOff(tf));
        end

        function enableSelectProtocol(obj, tf)
            set(obj.protocolPopupMenu, 'Enable', appbox.onOff(tf));
        end

        function p = getSelectedProtocol(obj)
            p = get(obj.protocolPopupMenu, 'Value');
        end

        function setSelectedProtocol(obj, p)
            set(obj.protocolPopupMenu, 'Value', p);
        end

        function setProtocolList(obj, names, values)
            set(obj.protocolPopupMenu, 'String', names);
            set(obj.protocolPopupMenu, 'Values', values);
        end

        function enableProtocolProperties(obj, tf)
            set(obj.protocolPropertyGrid, 'Enable', tf);
        end

        function f = getProtocolProperties(obj)
            f = get(obj.protocolPropertyGrid, 'Properties');
        end

        function setProtocolProperties(obj, fields)
            set(obj.protocolPropertyGrid, 'Properties', fields);
        end

        function updateProtocolProperties(obj, fields)
            obj.protocolPropertyGrid.UpdateProperties(fields);
        end

        function stopEditingProtocolProperties(obj)
            obj.protocolPropertyGrid.StopEditing();
        end

        function tf = isProtocolPreviewMinimized(obj)
            tf = get(obj.protocolPreviewBox, 'Minimized');
        end

        function enableProtocolLayoutDivider(obj, tf)
            enable = appbox.onOff(tf);
            set(obj.protocolLayout, 'DividerMarkings', enable);
            % TODO: Enable protocolLayout divider
            % set(obj.protocolLayout, 'DividerEnable', enable);
        end

        function setProtocolPreviewMinimized(obj, tf)
            set(obj.protocolPreviewBox, 'Minimized', tf);
        end

        function h = getProtocolPreviewMinimumHeight(obj)
            heights = get(obj.protocolLayout, 'MinimumHeights');
            h = heights(2);
        end

        function h = getProtocolPreviewHeight(obj)
            heights = get(obj.protocolLayout, 'Heights');
            h = heights(2);
        end

        function setProtocolPreviewHeight(obj, h)
            heights = get(obj.protocolLayout, 'Heights');
            heights(2) = h;
            set(obj.protocolLayout, 'Heights', heights);
        end

        function p = getProtocolPreviewPanel(obj)
            p = obj.protocolPreviewPanel;
        end

        function clearProtocolPreviewPanel(obj)
            delete(get(obj.protocolPreviewPanel, 'Children'));
        end

        function enableViewOnly(obj, tf)
            enable = appbox.onOff(tf);
            set(obj.acquireMenu.viewOnly, 'Enable', enable);
            set(obj.viewOnlyButton, 'Enable', enable);
        end

        function enableRecord(obj, tf)
            enable = appbox.onOff(tf);
            set(obj.acquireMenu.record, 'Enable', enable);
            set(obj.recordButton, 'Enable', enable);
        end

        function enablePause(obj, tf)
            enable = appbox.onOff(tf);
            set(obj.acquireMenu.pause, 'Enable', enable);
            set(obj.pauseButton, 'Enable', enable);
        end

        function enableStop(obj, tf)
            enable = appbox.onOff(tf);
            set(obj.acquireMenu.stop, 'Enable', enable);
            set(obj.stopButton, 'Enable', enable);
        end

        function enableInitializeRig(obj, tf)
            set(obj.configureMenu.initializeRig, 'Enable', appbox.onOff(tf));
        end

        function enableConfigureDevices(obj, tf)
            set(obj.configureMenu.configureDevices, 'Enable', appbox.onOff(tf));
        end

        function enableConfigureOptions(obj, tf)
            set(obj.configureMenu.configureOptions, 'Enable', appbox.onOff(tf));
        end

        function addModule(obj, name, value)
            uimenu(obj.modulesMenu.root, ...
                'Label', name, ...
                'Callback', @(h,d)notify(obj, 'SelectedModule', symphonyui.ui.UiEventData(value)));
        end

        function setStatus(obj, s)
            if isempty(s)
                title = 'Symphony';
            else
                title = sprintf('Symphony (%s)', s);
            end
            set(obj.figureHandle, 'Name', title);
        end

    end

end
