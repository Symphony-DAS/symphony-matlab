classdef ExperimentView < symphonyui.ui.View

    events
        SelectedNode
        AddProperty
        RemoveProperty
        AddKeyword
        RemoveKeyword
        AddNote
        RemoveNote
    end

    properties (Access = private)
        experimentTree
        cardPanel
        emptyCard
        experimentCard
        epochGroupCard
        epochCard
        sourceCard
        tabPanel
        propertyGrid
        keywordsTable
        notesTable
        idToNode
    end

    properties (Constant)
        SOURCES_NODE_ID         = 'SOURCES_NODE_ID'
        EPOCH_GROUPS_NODE_ID    = 'EPOCH_GROUPS_NODE_ID'
        
        EMPTY_CARD          = 1
        EXPERIMENT_CARD     = 2
        SOURCE_CARD         = 3
        EPOCH_GROUP_CARD    = 4
        EPOCH_CARD          = 5
    end

    methods
        
        function createUi(obj)
            import symphonyui.ui.util.*;
            
            obj.idToNode = containers.Map();
            
            set(obj.figureHandle, 'Name', 'Experiment');
            set(obj.figureHandle, 'Position', screenCenter(500, 410));

            mainLayout = uiextras.HBoxFlex( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            masterLayout = uiextras.VBoxFlex( ...
                'Parent', mainLayout, ...
                'Spacing', 7);

            obj.experimentTree = uiextras.jTree.Tree( ...
                'Parent', masterLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'SelectionChangeFcn', @(h,d)notify(obj, 'SelectedNode'));
            root = obj.experimentTree.Root;
            root.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'experiment.png'));
            
            sources = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Sources', ...
                'Value', obj.SOURCES_NODE_ID);
            sources.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'folder.png'));
            obj.idToNode(obj.SOURCES_NODE_ID) = sources;
            
            groups = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Epoch Groups', ...
                'Value', obj.EPOCH_GROUPS_NODE_ID);
            groups.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'folder.png'));
            obj.idToNode(obj.EPOCH_GROUPS_NODE_ID) = groups;

            detailLayout = uiextras.VBox( ...
                'Parent', mainLayout);

            obj.cardPanel = uix.CardPanel( ...
                'Parent', detailLayout);
            
            % Empty card.
            emptyLayout = uiextras.VBox('Parent', obj.cardPanel); %#ok<NASGU>
            
            % Experiment card.
            experimentLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            experimentLabelSize = 60;
            obj.experimentCard.nameField = createLabeledTextField(experimentLayout, 'Name:', experimentLabelSize, 'Enable', 'off');
            obj.experimentCard.locationField = createLabeledTextField(experimentLayout, 'Location:', experimentLabelSize, 'Enable', 'off');
            obj.experimentCard.startTimeField = createLabeledTextField(experimentLayout, 'Start time:', experimentLabelSize, 'Enable', 'off');
            obj.experimentCard.purposeField = createLabeledTextField(experimentLayout, 'Purpose:', experimentLabelSize, 'Enable', 'off');
            obj.experimentCard.tabPanelParent = uix.Panel('Parent', experimentLayout, 'BorderType', 'none');
            set(experimentLayout, 'Sizes', [25 25 25 25 -1]);
            
            % Source card.
            sourceLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            sourceLabelSize = 60;
            obj.sourceCard.labelField = createLabeledTextField(sourceLayout, 'Label:', sourceLabelSize, 'Enable', 'off');
            obj.sourceCard.tabPanelParent = uix.Panel('Parent', sourceLayout, 'BorderType', 'none');
            set(sourceLayout, 'Sizes', [25 -1]);

            % Epoch group card.
            epochGroupLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            epochGroupLabelSize = 60;
            obj.epochGroupCard.labelField = createLabeledTextField(epochGroupLayout, 'Label:', epochGroupLabelSize, 'Enable', 'off');
            obj.epochGroupCard.startTimeField = createLabeledTextField(epochGroupLayout, 'Start time:', epochGroupLabelSize, 'Enable', 'off');
            obj.epochGroupCard.endTimeField = createLabeledTextField(epochGroupLayout, 'End time:', epochGroupLabelSize, 'Enable', 'off');
            obj.epochGroupCard.sourceField = createLabeledTextField(epochGroupLayout, 'Source:', epochGroupLabelSize, 'Enable', 'off');
            obj.epochGroupCard.tabPanelParent = uix.Panel('Parent', epochGroupLayout, 'BorderType', 'none');
            set(epochGroupLayout, 'Sizes', [25 25 25 25 -1]);
            
            % Epoch card.
            epochLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            obj.epochCard.tabPanelParent = uix.Panel('Parent', epochLayout, 'BorderType', 'none');
            set(epochLayout, 'Sizes', [-1]);
            
            % Tab panel.
            obj.tabPanel = uix.TabPanel( ...
                'Parent', obj.experimentCard.tabPanelParent, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            
            % Properties tab.
            propertiesLayout = uiextras.VBox( ...
                'Parent', obj.tabPanel);
            obj.propertyGrid = uiextras.jide.PropertyGrid(propertiesLayout);
            obj.createAddRemoveButtons(propertiesLayout, @(h,d)notify(obj, 'AddProperty'), @(h,d)notify(obj, 'RemoveProperty'));
            set(propertiesLayout, 'Sizes', [-1 25]);
            
            % Keywords tab.
            keywordsLayout = uiextras.VBox( ...
                'Parent', obj.tabPanel);
            obj.keywordsTable = createTable( ...
                'Parent', keywordsLayout, ...
                'Container', keywordsLayout, ...
                'Headers', {'Keywords'}, ...
                'Editable', false, ...
                'SelectionMode', javax.swing.ListSelectionModel.SINGLE_SELECTION, ...
                'Buttons', 'off');
            obj.keywordsTable.getTableScrollPane.getRowHeader.setVisible(0);
            obj.createAddRemoveButtons(keywordsLayout, @(h,d)notify(obj, 'AddKeyword'), @(h,d)notify(obj, 'RemoveKeyword'));
            set(keywordsLayout, 'Sizes', [-1 25]);
            
            % Notes tab.
            notesLayout = uiextras.VBox( ...
                'Parent', obj.tabPanel);
            obj.notesTable = createTable( ...
                'Parent', notesLayout, ...
                'Container', notesLayout, ...
                'Headers', {'Time', 'Text'}, ...
                'Editable', false, ...
                'SelectionMode', javax.swing.ListSelectionModel.SINGLE_SELECTION, ...
                'Buttons', 'off');
            obj.notesTable.getTableScrollPane.getRowHeader.setVisible(0);
            obj.notesTable.getTable.getColumnModel.getColumn(0).setMaxWidth(80);
            [~, removeButton] = obj.createAddRemoveButtons(notesLayout, @(h,d)notify(obj, 'AddNote'), @(h,d)notify(obj, 'RemoveNote'));
            set(removeButton, 'Enable', 'off');
            set(notesLayout, 'Sizes', [-1 25]);
            
            set(obj.tabPanel, 'TabTitles', {'Properties', 'Keywords', 'Notes'});
            set(obj.tabPanel, 'TabWidth', 70);
            
            set(obj.cardPanel, 'Selection', 1);

            set(mainLayout, 'Sizes', [-1 -2]);
        end

        function setSelectedCard(obj, index)
            set(obj.cardPanel, 'Selection', index);
            
            switch index
                case obj.EMPTY_CARD
                    return;
                case obj.EXPERIMENT_CARD
                    parent = obj.experimentCard.tabPanelParent;
                case obj.SOURCE_CARD
                    parent = obj.sourceCard.tabPanelParent;
                case obj.EPOCH_GROUP_CARD
                    parent = obj.epochGroupCard.tabPanelParent;
                case obj.EPOCH_CARD
                    parent = obj.epochCard.tabPanelParent;
            end
            set(obj.tabPanel, 'Parent', parent);
        end

        function setExperimentTreeRootNode(obj, name, id)
            root = obj.experimentTree.Root;
            set(root, ...
                'Name', name, ...
                'Value', id);
            obj.idToNode(id) = root;
        end
        
        function setExperimentName(obj, n)
            set(obj.experimentCard.nameField, 'String', n);
        end
        
        function setExperimentLocation(obj, l)
            set(obj.experimentCard.locationField, 'String', l);
        end
        
        function setExperimentStartTime(obj, t)
            set(obj.experimentCard.startTimeField, 'String', datestr(t, 14));
        end
        
        function setExperimentPurpose(obj, p)
            set(obj.experimentCard.purposeField, 'String', p);
        end
        
        function addSourceNode(obj, parentId, name, id)
            parent = obj.idToNode(parentId);
            node = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'source.png'));
            obj.idToNode(id) = node;
        end
        
        function setSourceLabel(obj, l)
            set(obj.sourceCard.labelField, 'String', l);
        end

        function addEpochGroupNode(obj, parentId, name, id)
            parent = obj.idToNode(parentId);
            node = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'group.png'));
            obj.idToNode(id) = node;
        end
        
        function setEpochGroupLabel(obj, l)
            set(obj.epochGroupCard.labelField, 'String', l);
        end
        
        function setEpochGroupStartTime(obj, t)
            set(obj.epochGroupCard.startTimeField, 'String', datestr(t, 14));
        end
        
        function setEpochGroupEndTime(obj, t)
            set(obj.epochGroupCard.endTimeField, 'String', datestr(t, 14));
        end
        
        function setEpochGroupSource(obj, s)
            set(obj.epochGroupCard.sourceField, 'String', s);
        end

        function setEpochGroupNodeCurrent(obj, id)
            node = obj.idToNode(id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'group_current.png'));
        end

        function setEpochGroupNodeNormal(obj, id)
            node = obj.idToNode(id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'group.png'));
        end

        function addEpochNode(obj, parentId, name, id)
            parent = obj.idToNode(parentId);
            node = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'epoch.png'));
            obj.idToNode(id) = node;
        end

        function collapseNode(obj, id)
            node = obj.idToNode(id);
            node.collapse();
        end

        function expandNode(obj, id)
            node = obj.idToNode(id);
            node.expand();
        end

        function id = getSelectedNode(obj)
            node = obj.experimentTree.SelectedNodes;
            id = get(node, 'Value');
        end

        function setSelectedNode(obj, id)
            node = obj.idToNode(id);
            obj.experimentTree.SelectedNodes = node;
        end
        
        function setProperties(obj, properties)
            set(obj.propertyGrid, 'Properties', properties);
        end
        
        function addProperty(obj, property)
            properties = get(obj.propertyGrid, 'Properties');
            set(obj.propertyGrid, 'Properties', [properties, property]);
        end
        
        function removeProperty(obj, property)
            properties = get(obj.propertyGrid, 'Properties');
            for i = 1:numel(properties)
                if strcmp(properties(i).Name, property)
                    properties(i) = [];
                    break;
                end
            end
            set(obj.propertyGrid, 'Properties', properties);
        end
        
        function p = getSelectedProperty(obj)
            p = obj.propertyGrid.GetSelectedProperty();
        end
        
        function setKeywords(obj, keywords)
            jtable = obj.keywordsTable.getTable();
            jtable.getModel().setRowCount(0);
            for i = 1:numel(keywords)
                obj.addKeyword(keywords{i});
            end
        end
        
        function addKeyword(obj, keyword)
            jtable = obj.keywordsTable.getTable();
            jtable.getModel().addRow({keyword});
            jtable.clearSelection();
            jtable.scrollRectToVisible(jtable.getCellRect(jtable.getRowCount()-1, 0, true));
        end
        
        function removeKeyword(obj, keyword)
            symphonyui.ui.util.removeRowValue(obj.keywordsTable, keyword);
        end
        
        function k = getSelectedKeyword(obj)
            k = symphonyui.ui.util.getSelectedRowValue(obj.keywordsTable);
        end
        
        function setNotes(obj, notes)
            jtable = obj.notesTable.getTable();
            jtable.getModel().setRowCount(0);
            for i = 1:numel(notes)
                obj.addNote(notes{i});
            end
        end
        
        function addNote(obj, note)
            jtable = obj.notesTable.getTable();
            jtable.getModel().addRow({datestr(note.date, 14), note.text});
            jtable.clearSelection();
            jtable.scrollRectToVisible(jtable.getCellRect(jtable.getRowCount()-1, 0, true));
        end

    end
    
    methods (Access = private)
        
        function [addButton, removeButton] = createAddRemoveButtons(obj, parent, addCallback, removeCallback)
            layout = uiextras.HBox( ...
                'Parent', parent, ...
                'Spacing', 0);
            uiextras.Empty('Parent', layout);
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
            set(layout, 'Sizes', [-1 25 25]);
        end
        
    end

end
