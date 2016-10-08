classdef DataManagerView < appbox.View

    events
        SelectedNodes
        ConfigureDevices
        AddSource
        SetSourceLabel
        SetExperimentPurpose
        BeginEpochGroup
        EndEpochGroup
        SplitEpochGroup
        MergeEpochGroups
        SetEpochGroupLabel
        SelectedEpochGroupSource
        SelectedEpochSignals
        SetEpochSignalConfigurationSetting
        SetProperty
        AddProperty
        RemoveProperty
        ShowHidePropertyDescription
        AddKeyword
        RemoveKeyword
        AddNote
        SelectedPreset
        AddPreset
        ManagePresets
        SendEntityToWorkspace
        DeleteEntity
    end

    properties (Access = private)
        toolbar
        configureDevicesTool
        addSourceTool
        beginEpochGroupTool
        endEpochGroupTool
        entityTree
        sourcesFolderNode
        epochGroupsFolderNode
        detailCardPanel
        emptyCard
        sourceCard
        experimentCard
        epochGroupCard
        epochBlockCard
        epochCard
        tabGroup
        propertiesTab
        keywordsTab
        notesTab
        parametersTab
        presetPopupMenu
    end

    properties (Constant)
        EMPTY_CARD         = 1
        SOURCE_CARD        = 2
        EXPERIMENT_CARD    = 3
        EPOCH_GROUP_CARD   = 4
        EPOCH_BLOCK_CARD   = 5
        EPOCH_CARD         = 6
    end

    methods

        function createUi(obj)
            import appbox.*;
            import symphonyui.ui.views.EntityNodeType;

            set(obj.figureHandle, ...
                'Name', 'Data Manager', ...
                'Position', screenCenter(800, 520));

            obj.toolbar = Menu(obj.figureHandle);
            obj.configureDevicesTool = obj.toolbar.addPushTool( ...
                'Label', 'Configure Devices', ...
                'Callback', @(h,d)notify(obj, 'ConfigureDevices'));
            obj.addSourceTool = obj.toolbar.addPushTool( ...
                'Label', 'Add Source', ...
                'Callback', @(h,d)notify(obj, 'AddSource'));
            obj.beginEpochGroupTool = obj.toolbar.addPushTool( ...
                'Label', 'Begin Epoch Group', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));
            obj.endEpochGroupTool = obj.toolbar.addPushTool( ...
                'Label', 'End Epoch Group', ...
                'Callback', @(h,d)notify(obj, 'EndEpochGroup'));

            mainLayout = uix.HBoxFlex( ...
                'Parent', obj.figureHandle, ...
                'DividerMarkings', 'off', ...
                'DividerBackgroundColor', [160/255 160/255 160/255], ...
                'Spacing', 1);

            masterLayout = uix.HBox( ...
                'Parent', mainLayout);

            obj.entityTree = uiextras.jTree.Tree( ...
                'Parent', masterLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'BorderType', 'none', ...
                'SelectionChangeFcn', @(h,d)notify(obj, 'SelectedNodes'), ...
                'SelectionType', 'discontiguous');

            root = obj.entityTree.Root;
            set(root, 'Value', struct('entity', [], 'type', EntityNodeType.EXPERIMENT));
            root.setIcon(symphonyui.app.App.getResource('icons', 'experiment.png'));
            rootMenu = uicontextmenu('Parent', obj.figureHandle);
            uimenu( ...
                'Parent', rootMenu, ...
                'Label', 'Add Source...', ...
                'Callback', @(h,d)notify(obj, 'AddSource'));
            uimenu( ...
                'Parent', rootMenu, ...
                'Label', 'Begin Epoch Group...', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));
            rootMenu = obj.addEntityContextMenus(rootMenu);
            set(root, 'UIContextMenu', rootMenu);

            sources = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Sources', ...
                'Value', struct('entity', [], 'type', EntityNodeType.SOURCES_FOLDER));
            sources.setIcon(symphonyui.app.App.getResource('icons', 'folder.png'));
            sourcesMenu = uicontextmenu('Parent', obj.figureHandle);
            uimenu( ...
                'Parent', sourcesMenu, ...
                'Label', 'Add Source...', ...
                'Callback', @(h,d)notify(obj, 'AddSource'));
            set(sources, 'UIContextMenu', sourcesMenu);
            obj.sourcesFolderNode = sources;

            groups = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Epoch Groups', ...
                'Value', struct('entity', [], 'type', EntityNodeType.EPOCH_GROUP_FOLDER));
            groups.setIcon(symphonyui.app.App.getResource('icons', 'folder.png'));
            groupsMenu = uicontextmenu('Parent', obj.figureHandle);
            uimenu( ...
                'Parent', groupsMenu, ...
                'Label', 'Begin Epoch Group...', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));
            set(groups, 'UIContextMenu', groupsMenu);
            obj.epochGroupsFolderNode = groups;

            detailLayout = uix.VBox( ...
                'Parent', mainLayout, ...
                'Padding', 11);

            obj.detailCardPanel = uix.CardPanel( ...
                'Parent', detailLayout);

            % Empty card.
            emptyLayout = uix.VBox( ...
                'Parent', obj.detailCardPanel);
            uix.Empty('Parent', emptyLayout);
            obj.emptyCard.text = uicontrol( ...
                'Parent', emptyLayout, ...
                'Style', 'text', ...
                'HorizontalAlignment', 'center');
            uix.Empty('Parent',emptyLayout);
            set(emptyLayout, ...
                'Heights', [-1 23 -1], ...
                'UserData', struct('Height', -1));

            % Source card.
            sourceLayout = uix.VBox( ...
                'Parent', obj.detailCardPanel, ...
                'Spacing', 7);
            sourceGrid = uix.Grid( ...
                'Parent', sourceLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', sourceGrid, ...
                'String', 'Label:');
            obj.sourceCard.labelField = uicontrol( ...
                'Parent', sourceGrid, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SetSourceLabel'));
            set(sourceGrid, ...
                'Widths', [35 -1], ...
                'Heights', 23);
            obj.sourceCard.annotationsLayout = uix.VBox( ...
                'Parent', sourceLayout);
            obj.sourceCard.presetLayout = uix.VBox( ...
                'Parent', sourceLayout);
            set(sourceLayout, ...
                'Heights', [layoutHeight(sourceGrid) -1 23]);

            % Experiment card.
            experimentLayout = uix.VBox( ...
                'Parent', obj.detailCardPanel, ...
                'Spacing', 7);
            experimentGrid = uix.Grid( ...
                'Parent', experimentLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', experimentGrid, ...
                'String', 'Purpose:');
            Label( ...
                'Parent', experimentGrid, ...
                'String', 'Start time:');
            Label( ...
                'Parent', experimentGrid, ...
                'String', 'End time:');
            obj.experimentCard.purposeField = uicontrol( ...
                'Parent', experimentGrid, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SetExperimentPurpose'));
            obj.experimentCard.startTimeField = uicontrol( ...
                'Parent', experimentGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.experimentCard.endTimeField = uicontrol( ...
                'Parent', experimentGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(experimentGrid, ...
                'Widths', [60 -1], ...
                'Heights', [23 23 23]);
            obj.experimentCard.annotationsLayout = uix.VBox( ...
                'Parent', experimentLayout);
            obj.experimentCard.presetLayout = uix.VBox( ...
                'Parent', experimentLayout);
            set(experimentLayout, ...
                'Heights', [layoutHeight(experimentGrid) -1 23]);

            % Epoch group card.
            epochGroupLayout = uix.VBox( ...
                'Parent', obj.detailCardPanel, ...
                'Spacing', 7);
            epochGroupGrid = uix.Grid( ...
                'Parent', epochGroupLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', epochGroupGrid, ...
                'String', 'Label:');
            Label( ...
                'Parent', epochGroupGrid, ...
                'String', 'Start time:');
            Label( ...
                'Parent', epochGroupGrid, ...
                'String', 'End time:');
            Label( ...
                'Parent', epochGroupGrid, ...
                'String', 'Source:');
            obj.epochGroupCard.labelField = uicontrol( ...
                'Parent', epochGroupGrid, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SetEpochGroupLabel'));
            obj.epochGroupCard.startTimeField = uicontrol( ...
                'Parent', epochGroupGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochGroupCard.endTimeField = uicontrol( ...
                'Parent', epochGroupGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochGroupCard.sourcePopupMenu = MappedPopupMenu( ...
                'Parent', epochGroupGrid, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SelectedEpochGroupSource'));
            set(epochGroupGrid, ...
                'Widths', [60 -1], ...
                'Heights', [23 23 23 23]);
            obj.epochGroupCard.annotationsLayout = uix.VBox( ...
                'Parent', epochGroupLayout);
            obj.epochGroupCard.presetLayout = uix.VBox( ...
                'Parent', epochGroupLayout);
            set(epochGroupLayout, ...
                'Heights', [layoutHeight(epochGroupGrid) -1 23]);

            % Epoch block card.
            epochBlockLayout = uix.VBox( ...
                'Parent', obj.detailCardPanel, ...
                'Spacing', 7);
            epochBlockGrid = uix.Grid( ...
                'Parent', epochBlockLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', epochBlockGrid, ...
                'String', 'Protocol ID:');
            Label( ...
                'Parent', epochBlockGrid, ...
                'String', 'Start time:');
            Label( ...
                'Parent', epochBlockGrid, ...
                'String', 'End time:');
            obj.epochBlockCard.protocolIdField = uicontrol( ...
                'Parent', epochBlockGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochBlockCard.startTimeField = uicontrol( ...
                'Parent', epochBlockGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochBlockCard.endTimeField = uicontrol( ...
                'Parent', epochBlockGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(epochBlockGrid, ...
                'Widths', [65 -1], ...
                'Heights', [23 23 23]);
            obj.epochBlockCard.annotationsLayout = uix.VBox( ...
                'Parent', epochBlockLayout);
            obj.epochBlockCard.presetLayout = uix.VBox( ...
                'Parent', epochBlockLayout);
            set(epochBlockLayout, ...
                'Heights', [layoutHeight(epochBlockGrid) -1 23]);

            % Epoch card.
            epochLayout = uix.VBox( ...
                'Parent', obj.detailCardPanel, ...
                'Spacing', 7);
            signalLayout = uix.HBox( ...
                'Parent', epochLayout, ...
                'Spacing', 7);
            signalMasterLayout = uix.VBox( ...
                'Parent', signalLayout);
            obj.epochCard.signalListBox = MappedListBox( ...
                'Parent', signalMasterLayout, ...
                'Max', 10, ...
                'Min', 1, ...
                'Enable', 'off', ...
                'Callback', @(h,d)notify(obj, 'SelectedEpochSignals'));
            signalDetailLayout = uix.VBox( ...
                'Parent', signalLayout, ...
                'Spacing', 7);
            obj.epochCard.panel = uipanel( ...
                'Parent', signalDetailLayout, ...
                'BorderType', 'line', ...
                'HighlightColor', [130/255 135/255 144/255], ...
                'BackgroundColor', 'w');
            obj.epochCard.axes = axes( ...
                'Parent', obj.epochCard.panel);
            yyaxis(obj.epochCard.axes, 'right');
            set(obj.epochCard.axes, 'YColor', 'black');
            yyaxis(obj.epochCard.axes, 'left');
            set(obj.epochCard.axes, 'YColor', 'black');
            obj.epochCard.grid = uiextras.jide.PropertyGrid(signalDetailLayout, ...
                'Callback', @(h,d)notify(obj, 'SetEpochSignalConfigurationSetting', symphonyui.ui.UiEventData(d)));
            set(signalDetailLayout, 'Heights', [-2 -1]);
            set(signalLayout, 'Widths', [-1 -2]);
            obj.epochCard.annotationsLayout = uix.VBox( ...
                'Parent', epochLayout);
            obj.epochCard.presetLayout = uix.VBox( ...
                'Parent', epochLayout);
            set(epochLayout, ...
                'Heights', [-2 -1 23]);

            % Tab group.
            obj.tabGroup = TabGroup( ...
                'Parent', obj.experimentCard.annotationsLayout);

            % Properties tab.
            obj.propertiesTab.tab = uitab( ...
                'Parent', [], ...
                'Title', 'Properties');
            obj.tabGroup.addTab(obj.propertiesTab.tab);
            propertiesLayout = uix.VBox( ...
                'Parent', obj.propertiesTab.tab, ...
                'Spacing', 1);
            obj.propertiesTab.grid = uiextras.jide.PropertyGrid(propertiesLayout, ...
                'BorderType', 'none', ...
                'DescriptionBorderType', 'none', ...
                'ShowDescription', true, ...
                'Callback', @(h,d)notify(obj, 'SetProperty', symphonyui.ui.UiEventData(d)));

            % Properties toolbar.
            propertiesToolbarLayout = uix.HBox( ...
                'Parent', propertiesLayout);
            obj.propertiesTab.showHideDescriptionButton = Button( ...
                'Parent', propertiesToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'show_description.png'), ...
                'TooltipString', 'Show/Hide Property Description', ...
                'Callback', @(h,d)notify(obj, 'ShowHidePropertyDescription'));
            uix.Empty('Parent', propertiesToolbarLayout);
            obj.propertiesTab.addButton = Button( ...
                'Parent', propertiesToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'add.png'), ...
                'TooltipString', 'Add Property...', ...
                'Callback', @(h,d)notify(obj, 'AddProperty'));
            obj.propertiesTab.removeButton = Button( ...
                'Parent', propertiesToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'remove.png'), ...
                'TooltipString', 'Remove Property', ...
                'Callback', @(h,d)notify(obj, 'RemoveProperty'));
            uix.Empty('Parent', propertiesToolbarLayout);
            set(propertiesToolbarLayout, 'Widths', [22 -1 22 22 1]);

            set(propertiesLayout, 'Heights', [-1 22]);

            % Keywords tab.
            obj.keywordsTab.tab = uitab( ...
                'Parent', [], ...
                'Title', 'Keywords');
            obj.tabGroup.addTab(obj.keywordsTab.tab);
            keywordsLayout = uix.VBox( ...
                'Parent', obj.keywordsTab.tab, ...
                'Spacing', 1);
            obj.keywordsTab.table = uiextras.jTable.Table( ...
                'Parent', keywordsLayout, ...
                'ColumnName', {'Keyword'}, ...
                'Data', {}, ...
                'BorderType', 'none', ...
                'Editable', 'off');

            % Keywords toolbar.
            keywordsToolbarLayout = uix.HBox( ...
                'Parent', keywordsLayout);
            uix.Empty('Parent', keywordsToolbarLayout);
            obj.keywordsTab.addButton = Button( ...
                'Parent', keywordsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'add.png'), ...
                'TooltipString', 'Add Keyword...', ...
                'Callback', @(h,d)notify(obj, 'AddKeyword'));
            obj.keywordsTab.removeButton = Button( ...
                'Parent', keywordsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'remove.png'), ...
                'TooltipString', 'Remove Keyword', ...
                'Callback', @(h,d)notify(obj, 'RemoveKeyword'));
            uix.Empty('Parent', keywordsToolbarLayout);
            set(keywordsToolbarLayout, 'Widths', [-1 22 22 1]);

            set(keywordsLayout, 'Heights', [-1 22]);

            % Notes tab.
            obj.notesTab.tab = uitab( ...
                'Parent', [], ...
                'Title', 'Notes');
            obj.tabGroup.addTab(obj.notesTab.tab);
            notesLayout = uix.VBox( ...
                'Parent', obj.notesTab.tab, ...
                'Spacing', 1);
            obj.notesTab.table = uiextras.jTable.Table( ...
                'Parent', notesLayout, ...
                'ColumnName', {'Time', 'Text'}, ...
                'ColumnPreferredWidth', [100 400],...
                'ColumnResizable', [true true], ...
                'Data', {}, ...
                'BorderType', 'none', ...
                'Editable', 'off');

            % Notes toolbar.
            notesToolbarLayout = uix.HBox( ...
                'Parent', notesLayout);
            uix.Empty('Parent', notesToolbarLayout);
            obj.notesTab.addButton = Button( ...
                'Parent', notesToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'add.png'), ...
                'TooltipString', 'Add Note...', ...
                'Callback', @(h,d)notify(obj, 'AddNote'));
            obj.notesTab.removeButton = Button( ...
                'Parent', notesToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'remove.png'), ...
                'TooltipString', 'Remove Note', ...
                'Enable', 'off');
            uix.Empty('Parent', notesToolbarLayout);
            set(notesToolbarLayout, 'Widths', [-1 22 22 1]);

            set(notesLayout, 'Heights', [-1 22]);

            % Parameters tab.
            obj.parametersTab.tab = uitab( ...
                'Parent', [], ...
                'Title', 'Parameters');
            obj.tabGroup.addTab(obj.parametersTab.tab);
            parametersLayout = uix.VBox( ...
                'Parent', obj.parametersTab.tab);
            obj.parametersTab.grid = uiextras.jide.PropertyGrid(parametersLayout, ...
                'BorderType', 'none', ...
                'EditorStyle', 'readonly');

            % Preset popupmenu.
            obj.presetPopupMenu = MappedPopupMenu( ...
                'Parent', obj.experimentCard.presetLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @obj.onSelectedPreset);

            % The default GetJControlFcn is far too slow because it uses findjobj. This is much faster but also very
            % fragile. The tradeoff is worth it here.
            function jcontrol = getPresetMenuJControl(control)
                parent = control.Parent.JavaFrame.getPrintableComponent();
                jcontrol = parent.getComponent(0).getComponent(0);
            end
            set(obj.presetPopupMenu, 'GetJControlFcn', @getPresetMenuJControl);

            set(mainLayout, 'Widths', [-1 -2.5]);
        end

        function show(obj)
            show@appbox.View(obj);
            set(obj.keywordsTab.table, 'ColumnHeaderVisible', 'off');
            set(obj.notesTab.table, 'ColumnHeaderVisible', 'off');
        end

        function close(obj)
            close@appbox.View(obj);
            obj.toolbar.close();
            obj.propertiesTab.grid.Close();
            obj.parametersTab.grid.Close();
        end

        function enableConfigureDevicesTool(obj, tf)
            set(obj.configureDevicesTool, 'Enable', appbox.onOff(tf));
        end

        function enableAddSourceTool(obj, tf)
            set(obj.addSourceTool, 'Enable', appbox.onOff(tf));
        end

        function enableBeginEpochGroupTool(obj, tf)
            set(obj.beginEpochGroupTool, 'Enable', appbox.onOff(tf));
        end

        function enableEndEpochGroupTool(obj, tf)
            set(obj.endEpochGroupTool, 'Enable', appbox.onOff(tf));
        end

        function setCardSelection(obj, index)
            set(obj.detailCardPanel, 'Selection', index);

            switch index
                case obj.SOURCE_CARD
                    set(obj.tabGroup, 'Parent', obj.sourceCard.annotationsLayout);
                    set(obj.presetPopupMenu, 'Parent', obj.sourceCard.presetLayout);
                case obj.EXPERIMENT_CARD
                    set(obj.tabGroup, 'Parent', obj.experimentCard.annotationsLayout);
                    set(obj.presetPopupMenu, 'Parent', obj.experimentCard.presetLayout);
                case obj.EPOCH_GROUP_CARD
                    set(obj.tabGroup, 'Parent', obj.epochGroupCard.annotationsLayout);
                    set(obj.presetPopupMenu, 'Parent', obj.epochGroupCard.presetLayout);
                case obj.EPOCH_BLOCK_CARD
                    set(obj.tabGroup, 'Parent', obj.epochBlockCard.annotationsLayout);
                    set(obj.presetPopupMenu, 'Parent', obj.epochBlockCard.presetLayout);
                case obj.EPOCH_CARD
                    set(obj.tabGroup, 'Parent', obj.epochCard.annotationsLayout);
                    set(obj.presetPopupMenu, 'Parent', obj.epochCard.presetLayout);
            end

            if index == obj.EPOCH_CARD || index == obj.EPOCH_BLOCK_CARD
                obj.tabGroup.addTab(obj.parametersTab.tab);
            else
                obj.tabGroup.removeTab(obj.parametersTab.tab);
            end
        end

        function setEmptyText(obj, t)
            set(obj.emptyCard.text, 'String', t);
        end

        function n = getSourcesFolderNode(obj)
            n = obj.sourcesFolderNode;
        end

        function enableAddSourceMenu(obj, node, tf) %#ok<INUSL>
            menu = get(node, 'UIContextMenu');
            children = get(menu, 'Children');
            index = arrayfun(@(c)isequal(get(c, 'Label'), 'Add Source...'), children);
            set(children(index), 'Enable', appbox.onOff(tf));
        end

        function n = addSourceNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.SOURCE;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons', 'source.png'));
            menu = uicontextmenu('Parent', obj.figureHandle);
            uimenu( ...
                'Parent', menu, ...
                'Label', 'Add Source...', ...
                'Callback', @(h,d)notify(obj, 'AddSource'));
            menu = obj.addEntityContextMenus(menu);
            set(n, 'UIContextMenu', menu);
        end
        
        function setSourceNodeNormal(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons', 'source.png'));
        end
        
        function setSourceNodeWarn(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons', 'source_warn.png'));
        end

        function enableSourceLabel(obj, tf)
            set(obj.sourceCard.labelField, 'Enable', appbox.onOff(tf));
        end

        function l = getSourceLabel(obj)
            l = get(obj.sourceCard.labelField, 'String');
        end

        function setSourceLabel(obj, l)
            set(obj.sourceCard.labelField, 'String', l);
        end

        function setExperimentNode(obj, name, entity)
            value = get(obj.entityTree.Root, 'Value');
            value.entity = entity;
            set(obj.entityTree.Root, ...
                'Name', name, ...
                'Value', value);
        end
        
        function setExperimentNodeNormal(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons', 'experiment.png'));
        end
        
        function setExperimentNodeWarn(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons', 'experiment_warn.png'));
        end

        function n = getExperimentNode(obj)
            n = obj.entityTree.Root;
        end

        function enableExperimentPurpose(obj, tf)
            set(obj.experimentCard.purposeField, 'Enable', appbox.onOff(tf));
        end

        function p = getExperimentPurpose(obj)
            p = get(obj.experimentCard.purposeField, 'String');
        end

        function setExperimentPurpose(obj, p)
            set(obj.experimentCard.purposeField, 'String', p);
        end

        function requestExperimentPurposeFocus(obj)
            obj.update();
            uicontrol(obj.experimentCard.purposeField);
        end

        function setExperimentStartTime(obj, t)
            set(obj.experimentCard.startTimeField, 'String', t);
        end

        function setExperimentEndTime(obj, t)
            set(obj.experimentCard.endTimeField, 'String', t);
        end

        function n = getEpochGroupsFolderNode(obj)
            n = obj.epochGroupsFolderNode;
        end

        function n = addEpochGroupNode(obj, parent, name, entity, index)
            if nargin < 5
                index = [];
            end
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.EPOCH_GROUP;
            n = uiextras.jTree.TreeNode( ...
                'Name', name, ...
                'Value', value);
            n.setParent(parent, index);
            n.setIcon(symphonyui.app.App.getResource('icons', 'group.png'));
            menu = uicontextmenu('Parent', obj.figureHandle);
            menu = obj.addEpochGroupContextMenus(menu);
            set(n, 'UIContextMenu', menu);
        end
        
        function setEpochGroupNodeCurrent(obj, node)
            node.setIcon(symphonyui.app.App.getResource('icons', 'group_current.png'));
            menu = uicontextmenu('Parent', obj.figureHandle);
            uimenu( ...
                'Parent', menu, ...
                'Label', 'Begin Epoch Group...', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));
            uimenu( ...
                'Parent', menu, ...
                'Label', 'End Epoch Group', ...
                'Callback', @(h,d)notify(obj, 'EndEpochGroup'));
            menu = obj.addEpochGroupContextMenus(menu);
            set(node, 'UIContextMenu', menu);
        end

        function setEpochGroupNodeNormal(obj, node)
            node.setIcon(symphonyui.app.App.getResource('icons', 'group.png'));
            menu = uicontextmenu('Parent', obj.figureHandle);
            menu = obj.addEpochGroupContextMenus(menu);
            set(node, 'UIContextMenu', menu);
        end
        
        function setEpochGroupNodeWarn(obj, node)
            node.setIcon(symphonyui.app.App.getResource('icons', 'group_warn.png'));
            menu = uicontextmenu('Parent', obj.figureHandle);
            menu = obj.addEpochGroupContextMenus(menu);
            set(node, 'UIContextMenu', menu);
        end

        function enableEpochGroupLabel(obj, tf)
            set(obj.epochGroupCard.labelField, 'Enable', appbox.onOff(tf));
        end

        function l = getEpochGroupLabel(obj)
            l = get(obj.epochGroupCard.labelField, 'String');
        end

        function setEpochGroupLabel(obj, l)
            set(obj.epochGroupCard.labelField, 'String', l);
        end

        function setEpochGroupStartTime(obj, t)
            set(obj.epochGroupCard.startTimeField, 'String', t);
        end

        function setEpochGroupEndTime(obj, t)
            set(obj.epochGroupCard.endTimeField, 'String', t);
        end

        function enableSelectEpochGroupSource(obj, tf)
            set(obj.epochGroupCard.sourcePopupMenu, 'Enable', appbox.onOff(tf));
        end

        function s = getSelectedEpochGroupSource(obj)
            s = get(obj.epochGroupCard.sourcePopupMenu, 'Value');
        end

        function setSelectedEpochGroupSource(obj, s)
            set(obj.epochGroupCard.sourcePopupMenu, 'Value', s);
        end

        function setEpochGroupSourceList(obj, names, values)
            set(obj.epochGroupCard.sourcePopupMenu, 'String', names);
            set(obj.epochGroupCard.sourcePopupMenu, 'Values', values);
        end

        function enableBeginEpochGroupMenu(obj, node, tf) %#ok<INUSL>
            menu = get(node, 'UIContextMenu');
            children = get(menu, 'Children');
            index = arrayfun(@(c)isequal(get(c, 'Label'), 'Begin Epoch Group...'), children);
            set(children(index), 'Enable', appbox.onOff(tf));
        end

        function enableEndEpochGroupMenu(obj, node, tf) %#ok<INUSL>
            menu = get(node, 'UIContextMenu');
            children = get(menu, 'Children');
            index = arrayfun(@(c)isequal(get(c, 'Label'), 'End Epoch Group'), children);
            set(children(index), 'Enable', appbox.onOff(tf));
        end

        function n = addEpochBlockNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.EPOCH_BLOCK;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons', 'block.png'));
            menu = uicontextmenu('Parent', obj.figureHandle);
            menu = obj.addEntityContextMenus(menu);
            set(n, 'UIContextMenu', menu);
        end
        
        function setEpochBlockNodeNormal(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons', 'block.png'));
        end
        
        function setEpochBlockNodeWarn(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons', 'block_warn.png'));
        end

        function setEpochBlockProtocolId(obj, i)
            set(obj.epochBlockCard.protocolIdField, 'String', i);
        end

        function setEpochBlockProtocolParameters(obj, properties)
            set(obj.parametersTab.grid, 'Properties', properties);
        end

        function setEpochBlockStartTime(obj, t)
            set(obj.epochBlockCard.startTimeField, 'String', t);
        end

        function setEpochBlockEndTime(obj, t)
            set(obj.epochBlockCard.endTimeField, 'String', t);
        end

        function n = addEpochNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.EPOCH;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons', 'epoch.png'));
            menu = uicontextmenu('Parent', obj.figureHandle);
            menu = obj.addEntityContextMenus(menu);
            set(n, 'UIContextMenu', menu);
        end
        
        function setEpochNodeNormal(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons', 'epoch.png'));
        end
        
        function setEpochNodeWarn(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons', 'epoch_warn.png'));
        end

        function clearEpochDataAxes(obj)
            yyaxis(obj.epochCard.axes, 'left');
            cla(obj.epochCard.axes);
            yyaxis(obj.epochCard.axes, 'right');
            cla(obj.epochCard.axes);
            legend(obj.epochCard.axes, 'off');
        end

        function setEpochDataXLabel(obj, label)
            xlabel(obj.epochCard.axes, label, ...
                'Interpreter', 'tex');
        end
        
        function setEpochDataYLabel(obj, label, lr)
            if nargin < 3
                lr = 'left';
            end
            yyaxis(obj.epochCard.axes, lr);
            ylabel(obj.epochCard.axes, label, ...
                'Interpreter', 'tex');
        end
        
        function setEpochDataYAxisVisible(obj, tf, lr)
            if nargin < 3
                lr = 'left';
            end
            yaxis = get(obj.epochCard.axes, 'YAxis');
            if strcmp(lr, 'left')
                i = 1;
            elseif strcmp(lr, 'right')
                i = 2;
            else
                error('lr must be left or right');
            end
            set(yaxis(i), 'Visible', appbox.onOff(tf));
        end

        function addEpochDataLine(obj, x, y, color, lr)
            if nargin < 5
                lr = 'left';
            end
            yyaxis(obj.epochCard.axes, lr);
            line(x, y, 'Parent', obj.epochCard.axes, 'Color', color);
        end

        function addEpochDataLegend(obj, str)
            legend(obj.epochCard.axes, str);
        end
        
        function enableSelectEpochSignal(obj, tf)
            set(obj.epochCard.signalListBox, 'Enable', appbox.onOff(tf));
        end

        function s = getSelectedEpochSignals(obj)
            s = get(obj.epochCard.signalListBox, 'Value');
        end

        function setEpochSignalList(obj, names, values)
            set(obj.epochCard.signalListBox, 'String', names);
            set(obj.epochCard.signalListBox, 'Values', values);
        end
        
        function setEpochSignalConfiguration(obj, fields)
            set(obj.epochCard.grid, 'Properties', fields);
        end
        
        function updateEpochSignalConfiguration(obj, fields)
            obj.epochCard.grid.UpdateProperties(fields);
        end

        function setEpochProtocolParameters(obj, fields)
            set(obj.parametersTab.grid, 'Properties', fields);
        end

        function n = getNodeName(obj, node) %#ok<INUSL>
            n = get(node, 'Name');
        end

        function setNodeName(obj, node, name) %#ok<INUSL>
            set(node, 'Name', name);
        end
        
        function i = getNodeIndex(obj, node) %#ok<INUSL>
            i = find(node.Parent.Children == node, 1);
        end
        
        function setNodeTooltip(obj, node, t) %#ok<INUSL>
            set(node, 'TooltipString', t);
        end

        function e = getNodeEntity(obj, node) %#ok<INUSL>
            v = get(node, 'Value');
            e = v.entity;
        end

        function t = getNodeType(obj, node) %#ok<INUSL>
            v = get(node, 'Value');
            t = v.type;
        end

        function removeNode(obj, node) %#ok<INUSL>
            node.delete();
        end

        function collapseNode(obj, node) %#ok<INUSL>
            node.collapse();
        end

        function expandNode(obj, node) %#ok<INUSL>
            node.expand();
        end

        function nodes = getSelectedNodes(obj)
            nodes = obj.entityTree.SelectedNodes;
        end

        function setSelectedNodes(obj, nodes)
            obj.entityTree.SelectedNodes = nodes;
        end

        function setPropertiesEditorStyle(obj, s)
            set(obj.propertiesTab.grid, 'EditorStyle', s);
        end

        function setShowPropertyDescription(obj, tf)
            set(obj.propertiesTab.grid, 'ShowDescription', tf);
        end

        function tf = getShowPropertyDescription(obj)
            tf = get(obj.propertiesTab.grid, 'ShowDescription');
        end

        function p = getSelectedProperty(obj)
            p = obj.propertiesTab.grid.GetSelectedProperty();
        end

        function f = getProperties(obj)
            f = get(obj.propertiesTab.grid, 'Properties');
        end

        function setProperties(obj, fields)
            set(obj.propertiesTab.grid, 'Properties', fields);
        end

        function updateProperties(obj, fields)
            obj.propertiesTab.grid.UpdateProperties(fields);
        end

        function stopEditingProperties(obj)
            obj.propertiesTab.grid.StopEditing();
        end

        function setKeywords(obj, data)
            set(obj.keywordsTab.table, 'Data', data);
        end

        function addKeyword(obj, keyword)
            obj.keywordsTab.table.addRow(keyword);
        end

        function removeKeyword(obj, keyword)
            keywords = obj.keywordsTab.table.getColumnData(1);
            index = find(cellfun(@(c)strcmp(c, keyword), keywords));
            obj.keywordsTab.table.removeRow(index); %#ok<FNDSB>
        end

        function k = getSelectedKeyword(obj)
            rows = get(obj.keywordsTab.table, 'SelectedRows');
            if isempty(rows)
                k = [];
            else
                k = obj.keywordsTab.table.getValueAt(rows(1), 1);
            end
        end

        function setNotes(obj, data)
            set(obj.notesTab.table, 'Data', data);
        end

        function addNote(obj, date, text)
            obj.notesTab.table.addRow({date, text});
        end

        function enableSelectPreset(obj, tf)
            set(obj.presetPopupMenu, 'Enable', appbox.onOff(tf));
        end

        function setPresetList(obj, names, values)
            set(obj.presetPopupMenu, 'String', [{'Presets...', 'Add...', 'Manage...'} names]);
            set(obj.presetPopupMenu, 'Values', [{'Presets...', 'Add...', 'Manage...'} values]);
            obj.presetPopupMenu.setSeparatorIndices(3);
        end

        function p = getSelectedPreset(obj)
            p = get(obj.presetPopupMenu, 'Value');
        end

        function resetSelectedPreset(obj)
            set(obj.presetPopupMenu, 'Value', 'Presets...');
        end

    end

    methods (Access = private)

        function onSelectedPreset(obj, control, ~)
            value = get(control, 'Value');
            string = get(control, 'String');
            selection = string{value};
            switch selection
                case 'Presets...'
                    % Do nothing.
                case 'Add...'
                    notify(obj, 'AddPreset');
                    obj.resetSelectedPreset();
                case 'Manage...'
                    notify(obj, 'ManagePresets');
                    obj.resetSelectedPreset();
                otherwise
                    notify(obj, 'SelectedPreset');
            end
        end
        
        function menu = addEpochGroupContextMenus(obj, menu)
            uimenu( ...
                'Parent', menu, ...
                'Label', 'Split Epoch Group...', ...
                'Separator', appbox.onOff(~isempty(get(menu, 'Children'))), ...
                'Callback', @(h,d)notify(obj, 'SplitEpochGroup'));
            uimenu( ...
                'Parent', menu, ...
                'Label', 'Merge Epoch Groups...', ...
                'Callback', @(h,d)notify(obj, 'MergeEpochGroups'));
            obj.addEntityContextMenus(menu);
        end

        function menu = addEntityContextMenus(obj, menu)
            uimenu( ...
                'Parent', menu, ...
                'Label', 'Send to Workspace', ...
                'Separator', appbox.onOff(~isempty(get(menu, 'Children'))), ...
                'Callback', @(h,d)notify(obj, 'SendEntityToWorkspace'));
            uimenu( ...
                'Parent', menu, ...
                'Label', 'Delete', ...
                'Callback', @(h,d)notify(obj, 'DeleteEntity'));
        end

    end

end
