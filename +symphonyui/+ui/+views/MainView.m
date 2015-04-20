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
        ShowRig
        ShowExperiment
        LoadRig
        Settings
        Documentation
        UserGroup
        AboutSymphony
    end

    properties (Access = private)
        fileMenu
        experimentMenu
        acquireMenu
        configureMenu
        viewMenu
        helpMenu
        protocolDropDown
        protocolPropertyGrid
        recordButton
        previewButton
        pauseButton
        stopButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Symphony');
            set(obj.figureHandle, 'Position', screenCenter(340, 280));

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
                'Accelerator', 'r', ...
                'Callback', @(h,d)notify(obj, 'Record'));
            obj.acquireMenu.preview = uimenu(obj.acquireMenu.root, ...
                'Label', 'Preview', ...
                'Accelerator', 'v', ...
                'Callback', @(h,d)notify(obj, 'Preview'));
            obj.acquireMenu.pause = uimenu(obj.acquireMenu.root, ...
                'Label', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.acquireMenu.stop = uimenu(obj.acquireMenu.root, ...
                'Label', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));
            
            % View menu.
            obj.viewMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'View');
            obj.viewMenu.viewRig = uimenu(obj.viewMenu.root, ...
                'Label', 'Rig', ...
                'Accelerator', '1', ...
                'Callback', @(h,d)notify(obj, 'ShowRig'));
            obj.viewMenu.viewExperiment = uimenu(obj.viewMenu.root, ...
                'Label', 'Experiment', ...
                'Accelerator', '2', ...
                'Callback', @(h,d)notify(obj, 'ShowExperiment'));
            obj.viewMenu.modulesMenu.root = uimenu(obj.viewMenu.root, ...
                'Label', 'Modules', ...
                'Separator', 'on');
            
            % Configure menu.
            obj.configureMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Configure');
            obj.configureMenu.loadRig = uimenu(obj.configureMenu.root, ...
                'Label', 'Load Rig...', ...
                'Callback', @(h,d)notify(obj, 'LoadRig'));
            obj.configureMenu.settings = uimenu(obj.configureMenu.root, ...
                'Label', 'Settings...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'Settings'));
            
            % Help menu.
            obj.helpMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Help');
            obj.helpMenu.documentation = uimenu(obj.helpMenu.root, ...
                'Label', 'Documentation', ...
                'Callback', @(h,d)notify(obj, 'Documentation'));
            obj.helpMenu.userGroup = uimenu(obj.helpMenu.root, ...
                'Label', 'User Group', ...
                'Callback', @(h,d)notify(obj, 'UserGroup'));
            obj.helpMenu.about = uimenu(obj.helpMenu.root, ...
                'Label', 'About Symphony', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'AboutSymphony'));

            iconsUrl = pathToUrl(symphonyui.app.App.getIconsPath());

            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            obj.protocolDropDown = createDropDownMenu(mainLayout, {''});
            set(obj.protocolDropDown, 'Callback', @(h,d)notify(obj, 'SelectedProtocol'));

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
            set(obj.protocolDropDown, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function p = getSelectedProtocol(obj)
            p = symphonyui.ui.util.getSelectedValue(obj.protocolDropDown);
        end

        function setSelectedProtocol(obj, p)
            symphonyui.ui.util.setSelectedValue(obj.protocolDropDown, p);
        end

        function setProtocolList(obj, p)
            symphonyui.ui.util.setStringList(obj.protocolDropDown, p);
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
        
        function enableShowExperiment(obj, tf)
            set(obj.viewMenu.viewExperiment, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function enableLoadRig(obj, tf)
            set(obj.configureMenu.loadRig, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableSettings(obj, tf)
            set(obj.configureMenu.settings, 'Enable', symphonyui.ui.util.onOff(tf));
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
