classdef ExperimentView < symphonyui.ui.View

    events
        SelectedNode
        ViewEpochGroupSource
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
        idMap
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
            
            obj.idMap = containers.Map();
            
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
            obj.idMap(obj.SOURCES_NODE_ID) = sources;
            
            groups = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Epoch Groups', ...
                'Value', obj.EPOCH_GROUPS_NODE_ID);
            groups.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'folder.png'));
            obj.idMap(obj.EPOCH_GROUPS_NODE_ID) = groups;

            detailLayout = uiextras.VBox( ...
                'Parent', mainLayout);

            obj.cardPanel = uix.CardPanel( ...
                'Parent', detailLayout);
            
            % Empty card.
            emptyLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel);
            
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
            
            % Tab panel
            obj.tabPanel = uix.TabPanel( ...
                'Parent', experimentLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'Padding', 11);
            uicontrol('Parent', obj.tabPanel, 'Background', 'r');
            uicontrol('Parent', obj.tabPanel, 'Background', 'b');
            uicontrol('Parent', obj.tabPanel, 'Background', 'g');
            set(obj.tabPanel, 'TabTitles', {'Properties', 'Keywords', 'Notes'});
            set(obj.tabPanel, 'TabWidth', 70);

            set(obj.cardPanel, 'Selection', 1);

            set(mainLayout, 'Sizes', [-1 -2]);
        end

        function setSelectedCard(obj, index)
            set(obj.cardPanel, 'Selection', index);
            
            switch index
                case obj.EMPTY_CARD
                    parent = [];
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
            obj.idMap(id) = root;
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
            parent = obj.idMap(parentId);
            node = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'source.png'));
            obj.idMap(id) = node;
        end
        
        function setSourceLabel(obj, l)
            set(obj.sourceCard.labelField, 'String', l);
        end

        function addEpochGroupNode(obj, parentId, name, id)
            parent = obj.idMap(parentId);
            node = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'group.png'));
            obj.idMap(id) = node;
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
            node = obj.idMap(id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'group_current.png'));
        end

        function setEpochGroupNodeNormal(obj, id)
            node = obj.idMap(id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'group.png'));
        end

        function addEpochNode(obj, parentId, name, id)
            parent = obj.idMap(parentId);
            node = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'epoch.png'));
            obj.idMap(id) = node;
        end

        function collapseNode(obj, id)
            node = obj.idMap(id);
            node.collapse();
        end

        function expandNode(obj, id)
            node = obj.idMap(id);
            node.expand();
        end

        function id = getSelectedNode(obj)
            node = obj.experimentTree.SelectedNodes;
            id = get(node, 'Value');
        end

        function setSelectedNode(obj, id)
            node = obj.idMap(id);
            obj.experimentTree.SelectedNodes = node;
        end

    end

end
