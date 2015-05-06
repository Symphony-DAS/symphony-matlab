classdef MainView < symphonyui.ui.View

    events
        NewExperiment
        OpenExperiment
        CloseExperiment
        Exit
        BeginEpochGroup
        EndEpochGroup
        AddSource
        SelectedProtocol
        SetProtocolProperty
        Record
        Preview
        Pause
        Stop
        ConfigureDeviceBackgrounds
        LoadRigConfiguration
        CreateRigConfiguration
        ConfigureOptions
        ShowRig
        ShowProtocol
        ShowExperiment
        ShowDocumentation
        ShowUserGroup
        ShowAbout
    end

    properties (Access = private)
        fileMenu
        experimentMenu
        acquireMenu
        configureMenu
        windowMenu
        helpMenu
        protocolPopupMenu
        protocolPropertyGrid
        recordButton
        previewButton
        pauseButton
        stopButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, ...
                'Name', 'Symphony', ...
            	'Position', screenCenter(370, 300));

            % File menu.
            obj.fileMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'File');
            obj.fileMenu.newExperiment = uimenu(obj.fileMenu.root, ...
                'Label', 'New Experiment...', ...
                'Callback', @(h,d)notify(obj, 'NewExperiment'));
            obj.fileMenu.openExperiment = uimenu(obj.fileMenu.root, ...
                'Label', 'Open Experiment...', ...
                'Callback', @(h,d)notify(obj, 'OpenExperiment'));
            obj.fileMenu.closeExperiment = uimenu(obj.fileMenu.root, ...
                'Label', 'Close', ...
                'Callback', @(h,d)notify(obj, 'CloseExperiment'));
            obj.fileMenu.exit = uimenu(obj.fileMenu.root, ...
                'Label', 'Exit', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'Exit'));

            % Experiment menu.
            obj.experimentMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Experiment');
            obj.experimentMenu.beginEpochGroup = uimenu(obj.experimentMenu.root, ...
                'Label', 'Begin Epoch Group...', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));
            obj.experimentMenu.endEpochGroup = uimenu(obj.experimentMenu.root, ...
                'Label', 'End Epoch Group', ...
                'Callback', @(h,d)notify(obj, 'EndEpochGroup'));
            obj.experimentMenu.addSource = uimenu(obj.experimentMenu.root, ...
                'Label', 'Add Source...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'AddSource'));

            % Acquire menu.
            obj.acquireMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Acquire');
            obj.acquireMenu.record = uimenu(obj.acquireMenu.root, ...
                'Label', 'Record', ...
                'Accelerator', 'R', ...
                'Callback', @(h,d)notify(obj, 'Record'));
            obj.acquireMenu.preview = uimenu(obj.acquireMenu.root, ...
                'Label', 'Preview', ...
                'Accelerator', 'V', ...
                'Callback', @(h,d)notify(obj, 'Preview'));
            obj.acquireMenu.pause = uimenu(obj.acquireMenu.root, ...
                'Label', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.acquireMenu.stop = uimenu(obj.acquireMenu.root, ...
                'Label', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));
            
            % Configure menu.
            obj.configureMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Configure');
            obj.configureMenu.configureDeviceBackgrounds = uimenu(obj.configureMenu.root, ...
                'Label', 'Device Backgrounds...', ...
                'Accelerator', 'B', ...
                'Callback', @(h,d)notify(obj, 'ConfigureDeviceBackgrounds'));
            obj.configureMenu.loadRigConfiguration = uimenu(obj.configureMenu.root, ...
                'Label', 'Load Rig Configuration...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'LoadRigConfiguration'));
            obj.configureMenu.createRigConfiguration = uimenu(obj.configureMenu.root, ...
                'Label', 'Create Rig Configuration...', ...
                'Callback', @(h,d)notify(obj, 'CreateRigConfiguration'));
            obj.configureMenu.configureOptions = uimenu(obj.configureMenu.root, ...
                'Label', 'Options...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'ConfigureOptions'));
            
            % Window menu.
            obj.windowMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Window');
            obj.windowMenu.showRig = uimenu(obj.windowMenu.root, ...
                'Label', 'Rig', ...
                'Accelerator', '1', ...
                'Callback', @(h,d)notify(obj, 'ShowRig'));
            obj.windowMenu.showProtocol = uimenu(obj.windowMenu.root, ...
                'Label', 'Protocol', ...
                'Accelerator', '2');
            obj.windowMenu.showExperiment = uimenu(obj.windowMenu.root, ...
                'Label', 'Experiment', ...
                'Accelerator', '3', ...
                'Callback', @(h,d)notify(obj, 'ShowExperiment'));
            obj.windowMenu.modulesMenu.root = uimenu(obj.windowMenu.root, ...
                'Label', 'Modules', ...
                'Separator', 'on');
            
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
            
            iconsPath = symphonyui.app.App.getIconsPath();
            if iconsPath(1) == filesep
                iconsPath(1) = [];
            end
            iconsUrl = strrep(['file:/' iconsPath '/'],'\','/');

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
            
            obj.recordButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'record_big.png'] '"/></html>'], ...
                'TooltipString', 'Record', ...
                'Callback', @(h,d)notify(obj, 'Record'));
            obj.previewButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'preview_big.png'] '"/></html>'], ...
                'TooltipString', 'Preview', ...
                'Callback', @(h,d)notify(obj, 'Preview'));
            obj.pauseButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'pause_big.png'] '"/></html>'], ...
                'TooltipString', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.stopButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'stop_big.png'] '"/></html>'], ...
                'TooltipString', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));

            set(mainLayout, 'Sizes', [25 -1 34]);
        end

        function close(obj)
            close@symphonyui.ui.View(obj);
            obj.protocolPropertyGrid.Close();
        end

        function enableNewExperiment(obj, tf)
            set(obj.fileMenu.newExperiment, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableOpenExperiment(obj, tf)
            set(obj.fileMenu.openExperiment, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableCloseExperiment(obj, tf)
            set(obj.fileMenu.closeExperiment, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableBeginEpochGroup(obj, tf)
            set(obj.experimentMenu.beginEpochGroup, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableEndEpochGroup(obj, tf)
            set(obj.experimentMenu.endEpochGroup, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableAddSource(obj, tf)
            set(obj.experimentMenu.addSource, 'Enable', symphonyui.ui.util.onOff(tf));
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

        function enableRecord(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquireMenu.record, 'Enable', enable);
            set(obj.recordButton, 'Enable', enable);
        end

        function enablePreview(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquireMenu.preview, 'Enable', enable);
            set(obj.previewButton, 'Enable', enable);
        end

        function enablePause(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquireMenu.pause, 'Enable', enable);
            set(obj.pauseButton, 'Enable', enable);
        end

        function enableStop(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquireMenu.stop, 'Enable', enable);
            set(obj.stopButton, 'Enable', enable);
        end
        
        function enableConfigureDeviceBackgrounds(obj, tf)
            set(obj.configureMenu.configureDeviceBackgrounds, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableLoadRigConfiguration(obj, tf)
            set(obj.configureMenu.loadRigConfiguration, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableCreateRigConfiguration(obj, tf)
            set(obj.configureMenu.createRigConfiguration, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableConfigureOptions(obj, tf)
            set(obj.configureMenu.configureOptions, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableShowExperiment(obj, tf)
            set(obj.windowMenu.showExperiment, 'Enable', symphonyui.ui.util.onOff(tf));
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
