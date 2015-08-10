classdef MainView < symphonyui.ui.View

    events
        NewFile
        OpenFile
        CloseFile
        Exit
        AddSource
        BeginEpochGroup
        EndEpochGroup
        ShowDataManager
        SelectedProtocol
        SetProtocolProperty
        ViewProtocol
        RecordProtocol
        StopProtocol
        ShowProtocolPreview
        InitializeRig
        ConfigureDeviceBackgrounds
        ConfigureOptions
        ShowDocumentation
        ShowUserGroup
        ShowAbout
    end

    properties (Access = private)
        fileMenu
        documentMenu
        acquireMenu
        configureMenu
        helpMenu
        protocolPopupMenu
        protocolPropertyGrid
        viewProtocolButton
        recordProtocolButton
        stopProtocolButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;
            import symphonyui.app.App;

            set(obj.figureHandle, ...
                'Name', 'Symphony', ...
            	'Position', screenCenter(320, 280));

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
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));
            obj.documentMenu.endEpochGroup = uimenu(obj.documentMenu.root, ...
                'Label', 'End Epoch Group', ...
                'Callback', @(h,d)notify(obj, 'EndEpochGroup'));
            obj.documentMenu.showDataManager = uimenu(obj.documentMenu.root, ...
                'Label', 'Data Manager', ...
                'Separator', 'on', ...
                'Accelerator', 'D', ...
                'Callback', @(h,d)notify(obj, 'ShowDataManager'));

            % Acquire menu.
            obj.acquireMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Acquire');
            obj.acquireMenu.viewProtocol = uimenu(obj.acquireMenu.root, ...
                'Label', 'View Only', ...
                'Accelerator', 'V', ...
                'Callback', @(h,d)notify(obj, 'ViewProtocol'));
            obj.acquireMenu.recordProtocol = uimenu(obj.acquireMenu.root, ...
                'Label', 'Record', ...
                'Accelerator', 'R', ...
                'Callback', @(h,d)notify(obj, 'RecordProtocol'));
            obj.acquireMenu.stopProtocol = uimenu(obj.acquireMenu.root, ...
                'Label', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'StopProtocol'));
            obj.acquireMenu.showProtocolPreview = uimenu(obj.acquireMenu.root, ...
                'Label', 'Protocol Preview', ...
                'Separator', 'on', ...
                'Accelerator', 'P', ...
                'Callback', @(h,d)notify(obj, 'ShowProtocolPreview'));
            
            % Configure menu.
            obj.configureMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Configure');
            obj.configureMenu.initializeRig = uimenu(obj.configureMenu.root, ...
                'Label', 'Initialize Rig...', ...
                'Callback', @(h,d)notify(obj, 'InitializeRig'));
            obj.configureMenu.configureDeviceBackgrounds = uimenu(obj.configureMenu.root, ...
                'Label', 'Device Backgrounds...', ...
                'Accelerator', 'B', ...
                'Callback', @(h,d)notify(obj, 'ConfigureDeviceBackgrounds'));
            obj.configureMenu.configureOptions = uimenu(obj.configureMenu.root, ...
                'Label', 'Options...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'ConfigureOptions'));
            
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

            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            obj.protocolPopupMenu = MappedPopupMenu( ...
                'Parent', mainLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SelectedProtocol'));

            obj.protocolPropertyGrid = uiextras.jide.PropertyGrid(mainLayout, ...
                'Callback', @(h,d)notify(obj, 'SetProtocolProperty', d));
            
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 1);
            
            path2Url = @(path)strrep(['file:/' path '/'],'\','/');
            
            obj.viewProtocolButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' path2Url(App.getResource('icons/view_only_big.png')) '"/></html>'], ...
                'TooltipString', 'View Only', ...
                'Callback', @(h,d)notify(obj, 'ViewProtocol'));
            obj.recordProtocolButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' path2Url(App.getResource('icons/record_big.png')) '"/></html>'], ...
                'TooltipString', 'Record', ...
                'Callback', @(h,d)notify(obj, 'RecordProtocol'));
            obj.stopProtocolButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' path2Url(App.getResource('icons/stop_big.png')) '"/></html>'], ...
                'TooltipString', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'StopProtocol'));

            set(mainLayout, 'Sizes', [25 -1 34]);
        end

        function close(obj)
            close@symphonyui.ui.View(obj);
            obj.protocolPropertyGrid.Close();
        end

        function enableNewFile(obj, tf)
            set(obj.fileMenu.newFile, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableOpenFile(obj, tf)
            set(obj.fileMenu.openFile, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableCloseFile(obj, tf)
            set(obj.fileMenu.closeFile, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableAddSource(obj, tf)
            set(obj.documentMenu.addSource, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableBeginEpochGroup(obj, tf)
            set(obj.documentMenu.beginEpochGroup, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableEndEpochGroup(obj, tf)
            set(obj.documentMenu.endEpochGroup, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableShowDataManager(obj, tf)
            set(obj.documentMenu.showDataManager, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableSelectProtocol(obj, tf)
            set(obj.protocolPopupMenu, 'Enable', symphonyui.ui.util.onOff(tf));
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

        function p = getProtocolProperties(obj)
            p = get(obj.protocolPropertyGrid, 'Properties');
        end

        function setProtocolProperties(obj, properties)
            set(obj.protocolPropertyGrid, 'Properties', properties);
        end

        function updateProtocolProperties(obj, properties)
            obj.protocolPropertyGrid.UpdateProperties(properties);
        end

        function enableViewProtocol(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquireMenu.viewProtocol, 'Enable', enable);
            set(obj.viewProtocolButton, 'Enable', enable);
        end
        
        function enableRecordProtocol(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquireMenu.recordProtocol, 'Enable', enable);
            set(obj.recordProtocolButton, 'Enable', enable);
        end

        function enableStopProtocol(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquireMenu.stopProtocol, 'Enable', enable);
            set(obj.stopProtocolButton, 'Enable', enable);
        end

        function enableShowProtocolPreview(obj, tf)
            set(obj.acquireMenu.showProtocolPreview, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableInitializeRig(obj, tf)
            set(obj.configureMenu.initializeRig, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableConfigureDeviceBackgrounds(obj, tf)
            set(obj.configureMenu.configureDeviceBackgrounds, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableConfigureOptions(obj, tf)
            set(obj.configureMenu.configureOptions, 'Enable', symphonyui.ui.util.onOff(tf));
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
