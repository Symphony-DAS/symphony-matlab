classdef MainView < symphonyui.ui.View

    events
        NewExperiment
        OpenExperiment
        CloseExperiment
        Exit
        BeginEpochGroup
        EndEpochGroup
        AddSource
        ViewExperiment
        SelectedProtocol
        SetProtocolProperty
        Record
        Preview
        Pause
        Stop
        LoadRigConfiguration
        Settings
        Documentation
        UserGroup
        AboutSymphony
    end

    properties (Access = private)
        fileMenu
        experimentMenu
        acquisitionMenu
        toolsMenu
        helpMenu
        protocolDropDown
        protocolPropertyGrid
        warningIcon
        recordButton
        previewButton
        pauseButton
        stopButton
        progressIndicatorIcon
        viewExperimentButton
        statusText
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Symphony');
            set(obj.figureHandle, 'Position', screenCenter(300, 260));

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
            obj.experimentMenu.viewExperiment = uimenu(obj.experimentMenu.root, ...
                'Label', 'View Experiment', ...
                'Separator', 'on', ...
                'Accelerator', 'e', ...
                'Callback', @(h,d)notify(obj, 'ViewExperiment'));

            % Acquisition menu.
            obj.acquisitionMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Acquisition');
            obj.acquisitionMenu.record = uimenu(obj.acquisitionMenu.root, ...
                'Label', 'Record', ...
                'Accelerator', 'r', ...
                'Callback', @(h,d)notify(obj, 'Record'));
            obj.acquisitionMenu.preview = uimenu(obj.acquisitionMenu.root, ...
                'Label', 'Preview', ...
                'Accelerator', 'v', ...
                'Callback', @(h,d)notify(obj, 'Preview'));
            obj.acquisitionMenu.pause = uimenu(obj.acquisitionMenu.root, ...
                'Label', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.acquisitionMenu.stop = uimenu(obj.acquisitionMenu.root, ...
                'Label', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));

            % Tools menu.
            obj.toolsMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Tools');
            obj.toolsMenu.modulesMenu.root = uimenu(obj.toolsMenu.root, ...
                'Label', 'Modules');
            obj.toolsMenu.loadRigConfiguration = uimenu(obj.toolsMenu.root, ...
                'Label', 'Load Rig Configuration...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'LoadRigConfiguration'));
            obj.toolsMenu.settings = uimenu(obj.toolsMenu.root, ...
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
                'Parent', mainLayout);
            
            label = javax.swing.JLabel(['<html><img src="' [iconsUrl 'warning.png'] '" align="right"/></html>']);
            label.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            label.setVisible(false);
            obj.warningIcon = javacomponent(label, [], controlsLayout);
            
            uiextras.Empty('Parent', controlsLayout);
            
            label = javax.swing.JLabel(['<html><img src="' [iconsUrl 'control_panel_left.png'] '"/></html>']);
            %label.setVisible(false);
            javacomponent(label, [], controlsLayout);
            
            controlsPanel = uix.Panel( ...
                'Parent', controlsLayout, ...
                'BorderType', 'none');
            panelLayout = uiextras.HBox( ...
                'Parent', controlsPanel);
            obj.recordButton = uicontrol( ...
                'Parent', panelLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'record_big.png'] '"/></html>'], ...
                'TooltipString', 'Record', ...
                'Callback', @(h,d)notify(obj, 'Record'));
            obj.previewButton = uicontrol( ...
                'Parent', panelLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'preview_big.png'] '"/></html>'], ...
                'TooltipString', 'Preview', ...
                'Callback', @(h,d)notify(obj, 'Preview'));
            obj.pauseButton = uicontrol( ...
                'Parent', panelLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'pause_big.png'] '"/></html>'], ...
                'TooltipString', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.stopButton = uicontrol( ...
                'Parent', panelLayout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'stop_big.png'] '"/></html>'], ...
                'TooltipString', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));
            set(panelLayout, 'Sizes', [34 34 34 34]);
            
            label = javax.swing.JLabel(['<html><img src="' [iconsUrl 'control_panel_right.png'] '"/></html>']);
            %label.setVisible(false);
            javacomponent(label, [], controlsLayout);
            
            uiextras.Empty('Parent', controlsLayout);
            
            label = javax.swing.JLabel(['<html><img src="' [iconsUrl 'progress_indicator.gif'] '"/></html>']);
            label.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            %label.setVisible(false);
            obj.progressIndicatorIcon = javacomponent(label, [], controlsLayout);
            
            % Avoid using findjobj (extremely slow).
            try %#ok<TRYNC>
                drawnow;
                layout = obj.progressIndicatorIcon.getParent().getParent().getParent();
                panel = layout.getComponent(2).getComponent(0);
                panel.setBorder(javax.swing.BorderFactory.createMatteBorder(1, 0, 1, 0, java.awt.Color(160/255,160/255,160/255)));
                container = panel.getComponent(0).getComponent(0).getComponent(0).getComponent(0);
                container.getComponent(0).getComponent(0).setFlyOverAppearance(true);
                container.getComponent(1).getComponent(0).setFlyOverAppearance(true);
                container.getComponent(2).getComponent(0).setFlyOverAppearance(true);
                container.getComponent(3).getComponent(0).setFlyOverAppearance(true);
            end

            set(controlsLayout, 'Sizes', [36 -1 18 34*4 18 -1 36]);

            set(mainLayout, 'Sizes', [25 -1 36]);
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

        function enableAddSource(obj, tf)
            set(obj.experimentMenu.addSource, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableBeginEpochGroup(obj, tf)
            set(obj.experimentMenu.beginEpochGroup, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableEndEpochGroup(obj, tf)
            set(obj.experimentMenu.endEpochGroup, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableViewExperiment(obj, tf)
            set(obj.experimentMenu.viewExperiment, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableLoadRigConfiguration(obj, tf)
            set(obj.toolsMenu.loadRigConfiguration, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function enableSettings(obj, tf)
            set(obj.toolsMenu.settings, 'Enable', symphonyui.ui.util.onOff(tf));
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
            set(obj.acquisitionMenu.record, 'Enable', enable);
            set(obj.recordButton, 'Enable', enable);
        end

        function enablePreview(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquisitionMenu.preview, 'Enable', enable);
            set(obj.previewButton, 'Enable', enable);
        end

        function enablePause(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquisitionMenu.pause, 'Enable', enable);
            set(obj.pauseButton, 'Enable', enable);
        end

        function enableStop(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.acquisitionMenu.stop, 'Enable', enable);
            set(obj.stopButton, 'Enable', enable);
        end

        function enableProgressIndicator(obj, tf)
            obj.progressIndicatorIcon.setVisible(tf);
        end

        function enableWarning(obj, tf)
            obj.warningIcon.setVisible(tf);
        end

        function setWarning(obj, s)
            obj.warningIcon.setToolTipText(s);
        end

        function setStatus(obj, s)
            if isempty(s)
                title = 'Symphony';
            else
                title = sprintf('Symphony (%s)', s);
            end
            set(obj.figureHandle, 'Name', title);
            obj.progressIndicatorIcon.setToolTipText(s);
        end

    end

end
