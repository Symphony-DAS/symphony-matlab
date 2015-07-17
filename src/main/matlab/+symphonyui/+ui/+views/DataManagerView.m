classdef DataManagerView < symphonyui.ui.View

    events
        AddSource
        BeginEpochGroup
        EndEpochGroup
        SelectedNodes
        AddProperty
        RemoveProperty
        AddKeyword
        RemoveKeyword
        AddNote
        SendToWorkspace
        DeleteEntity
    end

    properties (Access = private)
        addSourceButtons
        beginEpochGroupButtons
        endEpochGroupButtons
        entityTree
        devicesFolderNode
        sourcesFolderNode
        epochGroupsFolderNode
        tabGroup
        dataCardPanel
        emptyCard
        deviceCard
        sourceCard
        experimentCard
        epochGroupCard
        epochBlockCard
        epochCard
        propertiesTab
        keywordsTab
        notesTab
    end
    
    properties (Constant)
        EMPTY_DATA_CARD         = 1
        DEVICE_DATA_CARD        = 2
        SOURCE_DATA_CARD        = 3
        EXPERIMENT_DATA_CARD    = 4
        EPOCH_GROUP_DATA_CARD   = 5
        EPOCH_BLOCK_DATA_CARD   = 6
        EPOCH_DATA_CARD         = 7
        
        DATA_TAB                = 1
        PROPERTIES_TAB          = 2
        KEYWORDS_TAB            = 3
        NOTES_TAB               = 4
    end
    
    methods

        function createUi(obj)
            import symphonyui.ui.util.*;
            import symphonyui.ui.views.EntityNodeType;

            set(obj.figureHandle, 'Name', 'Data Manager');
            set(obj.figureHandle, 'Position', screenCenter(559, 350));

            % Toolbar.
            toolbar = uitoolbar( ...
                'Parent', obj.figureHandle);
            obj.addSourceButtons.tool = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Add Source...', ...
                'ClickedCallback', @(h,d)notify(obj, 'AddSource'));
            setIconImage(obj.addSourceButtons.tool, symphonyui.app.App.getResource('icons/source_add.png'));
            obj.beginEpochGroupButtons.tool = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Begin Epoch Group...', ...
                'Separator', 'on', ...
                'ClickedCallback', @(h,d)notify(obj, 'BeginEpochGroup'));
            setIconImage(obj.beginEpochGroupButtons.tool, symphonyui.app.App.getResource('icons/group_begin.png'));
            obj.endEpochGroupButtons.tool = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'End Epoch Group', ...
                'ClickedCallback', @(h,d)notify(obj, 'EndEpochGroup'));
            setIconImage(obj.endEpochGroupButtons.tool, symphonyui.app.App.getResource('icons/group_end.png'));

            mainLayout = uix.HBoxFlex( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            masterLayout = uix.VBoxFlex( ...
                'Parent', mainLayout, ...
                'Spacing', 7);

            obj.entityTree = uiextras.jTree.Tree( ...
                'Parent', masterLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'SelectionChangeFcn', @(h,d)notify(obj, 'SelectedNodes'), ...
                'SelectionType', 'discontiguous');
            
            treeMenu = uicontextmenu('Parent', obj.figureHandle);
            obj.addSourceButtons.menu = uimenu( ...
                'Parent', treeMenu, ...
                'Label', 'Add Source...', ...
                'Callback', @(h,d)notify(obj, 'AddSource'));
            obj.beginEpochGroupButtons.menu = uimenu( ...
                'Parent', treeMenu, ...
                'Label', 'Begin Epoch Group...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));
            obj.endEpochGroupButtons.menu = uimenu( ...
                'Parent', treeMenu, ...
                'Label', 'End Epoch Group', ...
                'Callback', @(h,d)notify(obj, 'EndEpochGroup'));
            set(obj.entityTree, 'UIContextMenu', treeMenu);
            
            root = obj.entityTree.Root;
            set(root, 'Value', struct('entity', [], 'type', EntityNodeType.EXPERIMENT));
            root.setIcon(symphonyui.app.App.getResource('icons/experiment.png'));
            set(root, 'UIContextMenu', obj.createEntityContextMenu());
            
            devices = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Devices', ...
                'Value', struct('entity', [], 'type', EntityNodeType.NON_ENTITY));
            devices.setIcon(symphonyui.app.App.getResource('icons/folder.png'));
            obj.devicesFolderNode = devices;

            sources = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Sources', ...
                'Value', struct('entity', [], 'type', EntityNodeType.NON_ENTITY));
            sources.setIcon(symphonyui.app.App.getResource('icons/folder.png'));
            obj.sourcesFolderNode = sources;

            groups = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Epoch Groups', ...
                'Value', struct('entity', [], 'type', EntityNodeType.NON_ENTITY));
            groups.setIcon(symphonyui.app.App.getResource('icons/folder.png'));
            obj.epochGroupsFolderNode = groups;

            detailLayout = uix.VBox( ...
                'Parent', mainLayout);

            % Tab group.
            obj.tabGroup = TabGroup( ...
                'Parent', detailLayout);
            
            % Data tab.
            dataTab = obj.tabGroup.addTab( ...
                'Title', 'Data');
            
            obj.dataCardPanel = uix.CardPanel( ...
                'Parent', dataTab);
            
            % Empty card.
            emptyLayout = uix.VBox('Parent', obj.dataCardPanel); %#ok<NASGU>
            
            % Device card.
            deviceLayout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            Label( ...
                'Parent', deviceLayout, ...
                'String', 'Name:');
            Label( ...
                'Parent', deviceLayout, ...
                'String', 'Manufacturer:');
            obj.deviceCard.nameField = uicontrol( ...
                'Parent', deviceLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.deviceCard.manufacturerField = uicontrol( ...
                'Parent', deviceLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(deviceLayout, ...
                'Widths', [80 -1], ...
                'Heights', [25 25]);
            
            % Source card.
            sourceLayout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            Label( ...
                'Parent', sourceLayout, ...
                'String', 'Label:');
            obj.sourceCard.labelField = uicontrol( ...
                'Parent', sourceLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(sourceLayout, ...
                'Widths', [35 -1], ...
                'Heights', 25);

            % Experiment card.
            experimentLayout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            Label( ...
                'Parent', experimentLayout, ...
                'String', 'Purpose:');
            Label( ...
                'Parent', experimentLayout, ...
                'String', 'Start time:');
            Label( ...
                'Parent', experimentLayout, ...
                'String', 'End time:');
            obj.experimentCard.purposeField = uicontrol( ...
                'Parent', experimentLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.experimentCard.startTimeField = uicontrol( ...
                'Parent', experimentLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.experimentCard.endTimeField = uicontrol( ...
                'Parent', experimentLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(experimentLayout, ...
                'Widths', [60 -1], ...
                'Heights', [25 25 25]);

            % Epoch group card.
            epochGroupLayout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            Label( ...
                'Parent', epochGroupLayout, ...
                'String', 'Label:');
            Label( ...
                'Parent', epochGroupLayout, ...
                'String', 'Start time:');
            Label( ...
                'Parent', epochGroupLayout, ...
                'String', 'End time:');
            Label( ...
                'Parent', epochGroupLayout, ...
                'String', 'Source:');
            obj.epochGroupCard.labelField = uicontrol( ...
                'Parent', epochGroupLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochGroupCard.startTimeField = uicontrol( ...
                'Parent', epochGroupLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochGroupCard.endTimeField = uicontrol( ...
                'Parent', epochGroupLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochGroupCard.sourceField = uicontrol( ...
                'Parent', epochGroupLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(epochGroupLayout, ...
                'Widths', [60 -1], ...
                'Heights', [25 25 25 25]);
            
            % Epoch block card.
            epochBlockLayout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            Label( ...
                'Parent', epochBlockLayout, ...
                'String', 'Protocol ID:');
            obj.epochBlockCard.protocolIdField = uicontrol( ...
                'Parent', epochBlockLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(epochBlockLayout, ...
                'Widths', [65 -1], ...
                'Heights', 25);
            
            % Epoch card.
            epochLayout = uix.VBox( ...
                'Parent', obj.dataCardPanel, ...
                'Spacing', 7);
            %set(epochLayout, 'Heights', -1);
            
            set(obj.dataCardPanel, 'Selection', 1);

            % Properties tab.
            obj.propertiesTab.tab = obj.tabGroup.addTab( ...
                'Title', 'Properties');
            obj.propertiesTab.layout = uix.VBox( ...
                'Parent', obj.propertiesTab.tab);
            obj.propertiesTab.table = Table( ...
                'Parent', obj.propertiesTab.layout, ...
                'ColumnName', {'Key', 'Value'}, ...
                'Editable', false);
            [a, r] = obj.createAddRemoveButtons(obj.propertiesTab.layout, @(h,d)notify(obj, 'AddProperty'), @(h,d)notify(obj, 'RemoveProperty'));
            obj.propertiesTab.addButton = a;
            obj.propertiesTab.removeButton = r;
            set(obj.propertiesTab.layout, 'Heights', [-1 25]);

            % Keywords tab.
            obj.keywordsTab.tab = obj.tabGroup.addTab( ...
                'Title', 'Keywords');
            obj.keywordsTab.layout = uix.VBox( ...
                'Parent', obj.keywordsTab.tab);
            obj.keywordsTab.table = Table( ...
                'Parent', obj.keywordsTab.layout, ...
                'ColumnName', {'Keywords'}, ...
                'Editable', false);
            [a, r] = obj.createAddRemoveButtons(obj.keywordsTab.layout, @(h,d)notify(obj, 'AddKeyword'), @(h,d)notify(obj, 'RemoveKeyword'));
            obj.keywordsTab.addButton = a;
            obj.keywordsTab.removeButton = r;
            set(obj.keywordsTab.layout, 'Heights', [-1 25]);

            % Notes tab.
            obj.notesTab.tab = obj.tabGroup.addTab( ...
                'Title', 'Notes');
            obj.notesTab.layout = uix.VBox( ...
                'Parent', obj.notesTab.tab);
            obj.notesTab.table = Table( ...
                'Parent', obj.notesTab.layout, ...
                'ColumnName', {'Time', 'Text'}, ...
                'ColumnWidth', {80}, ...
                'Editable', false);
            [a, r] = obj.createAddRemoveButtons(obj.notesTab.layout, @(h,d)notify(obj, 'AddNote'), []);
            obj.notesTab.addButton = a;
            obj.notesTab.removeButton = r;
            set(obj.notesTab.removeButton, 'Enable', 'off');
            set(obj.notesTab.layout, 'Heights', [-1 25]);

            set(mainLayout, 'Widths', [-1 -2]);
        end
        
        function setSelectedTab(obj, t)
            switch t
                case obj.DATA_TAB
                    tab = obj.dataTab.tab;
                case obj.PROPERTIES_TAB
                    tab = obj.propertiesTab.tab;
                case obj.KEYWORDS_TAB
                    tab = obj.keywordsTab.tab;
                case obj.NOTES_TAB
                    tab = obj.notesTab.tab;
                otherwise
                    error('Invalid tab');
            end
            set(obj.tabGroup, 'SelectedTab', tab);
        end
        
        function enableBeginEpochGroup(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.beginEpochGroupButtons.tool, 'Enable', enable);
            set(obj.beginEpochGroupButtons.menu, 'Enable', enable);
        end

        function enableEndEpochGroup(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.endEpochGroupButtons.tool, 'Enable', enable);
            set(obj.endEpochGroupButtons.menu, 'Enable', enable);
        end

        function setDataCardSelection(obj, index)
            set(obj.dataCardPanel, 'Selection', index);
        end
        
        function n = getDevicesFolderNode(obj)
            n = obj.devicesFolderNode;
        end

        function n = addDeviceNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.DEVICE;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/device.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
        end

        function setDeviceName(obj, n)
            set(obj.deviceCard.nameField, 'String', n);
        end
        
        function setDeviceManufacturer(obj, m)
            set(obj.deviceCard.manufacturerField, 'String', m);
        end
        
        function n = getSourcesFolderNode(obj)
            n = obj.sourcesFolderNode;
        end

        function n = addSourceNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.SOURCE;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/source.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
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
        
        function n = getExperimentNode(obj)
            n = obj.entityTree.Root;
        end

        function setExperimentPurpose(obj, p)
            set(obj.experimentCard.purposeField, 'String', p);
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

        function n = addEpochGroupNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.EPOCH_GROUP;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/group.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
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

        function setEpochGroupSource(obj, s)
            set(obj.epochGroupCard.sourceField, 'String', s);
        end

        function setEpochGroupNodeCurrent(obj, node)
            node.setIcon(symphonyui.app.App.getResource('icons/group_current.png'));
        end

        function setEpochGroupNodeNormal(obj, node)
            node.setIcon(symphonyui.app.App.getResource('icons/group.png'));
        end
        
        function n = addEpochBlockNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.EPOCH_BLOCK;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/block.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
        end
        
        function setEpochBlockProtocolId(obj, i)
            set(obj.epochBlockCard.protocolIdField, 'String', i);
        end

        function n = addEpochNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.EPOCH;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/epoch.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
        end
        
        function removeNode(obj, node)
            node.delete();
        end

        function collapseNode(obj, node)
            node.collapse();
        end

        function expandNode(obj, node)
            node.expand();
        end

        function nodes = getSelectedNodes(obj)
            nodes = obj.entityTree.SelectedNodes;
        end

        function setSelectedNodes(obj, nodes)
            obj.entityTree.SelectedNodes = nodes;
        end
        
        function enableProperties(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.propertiesTab.addButton, 'Enable', enable);
            set(obj.propertiesTab.removeButton, 'Enable', enable);
        end

        function setProperties(obj, data)
            set(obj.propertiesTab.table, 'Data', data);
        end
        
        function d = getProperties(obj)
            d = get(obj.propertiesTab.table, 'Data');
        end

        function addProperty(obj, key, value)
            obj.propertiesTab.table.addRow({key, value});
        end

        function removeProperty(obj, property)
            properties = obj.propertiesTab.table.getColumnData(1);
            index = find(cellfun(@(c)strcmp(c, property), properties));
            obj.propertiesTab.table.removeRow(index); %#ok<FNDSB>
        end

        function p = getSelectedProperty(obj)
            row = get(obj.propertiesTab.table, 'SelectedRow');
            p = obj.propertiesTab.table.getValueAt(row, 1);
        end
        
        function enableKeywords(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.keywordsTab.addButton, 'Enable', enable);
            set(obj.keywordsTab.removeButton, 'Enable', enable);
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
            row = get(obj.keywordsTab.table, 'SelectedRow');
            k = obj.keywordsTab.table.getValueAt(row, 1);
        end
        
        function enableNotes(obj, tf)
            set(obj.notesTab.addButton, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function setNotes(obj, data)
            set(obj.notesTab.table, 'Data', data);
        end

        function addNote(obj, date, text)
            obj.notesTab.table.addRow({date, text});
        end

    end

    methods (Access = private)

        function [addButton, removeButton] = createAddRemoveButtons(obj, parent, addCallback, removeCallback)
            layout = uix.HBox( ...
                'Parent', parent, ...
                'Spacing', 0);
            uix.Empty('Parent', layout);
            addButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', '+', ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize') + 1, ...
                'Callback', addCallback);
            removeButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', '-', ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize') + 1, ...
                'Callback', removeCallback);
            set(layout, 'Widths', [-1 25 25]);
        end
        
        function menu = createEntityContextMenu(obj)
            menu = uicontextmenu('Parent', obj.figureHandle);
            m.sendToWorkspaceMenu = uimenu( ...
                'Parent', menu, ...
                'Label', 'Send to Workspace', ...
                'Callback', @(h,d)notify(obj, 'SendToWorkspace'));
            m.deleteMenu = uimenu( ...
                'Parent', menu, ...
                'Label', 'Delete', ...
                'Callback', @(h,d)notify(obj, 'DeleteEntity'));
            set(menu, 'UserData', m);
        end

    end

end
