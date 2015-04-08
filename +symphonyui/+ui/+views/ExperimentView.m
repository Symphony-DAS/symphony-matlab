classdef ExperimentView < symphonyui.ui.View

    events
        SelectedNode
        ViewEpochGroupSource
    end

    properties (Access = private)
        experimentTree
        cardPanel
        experimentCard
        sourceCard
        epochGroupCard
        epochCard
        idMap
    end

    properties (Constant)
        EXPERIMENT_CARD = 1
        SOURCE_CARD = 2
        EPOCH_GROUP_CARD = 3
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Experiment');
            set(obj.figureHandle, 'Position', screenCenter(500, 400));

            mainLayout = uiextras.HBoxFlex( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            masterLayout = uiextras.VBox( ...
                'Parent', mainLayout);

            obj.experimentTree = uiextras.jTree.Tree( ...
                'Parent', masterLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'SelectionChangeFcn', @(h,d)notify(obj, 'SelectedNode'));

            detailLayout = uiextras.VBox( ...
                'Parent', mainLayout);

            obj.cardPanel = uix.CardPanel( ...
                'Parent', detailLayout);

            % Experiment card.
            experimentLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            experimentLabelSize = 60;
            obj.experimentCard.nameField = createLabeledTextField(experimentLayout, 'Name:', experimentLabelSize, 'Enable', 'off');
            obj.experimentCard.locationField = createLabeledTextField(experimentLayout, 'Location:', experimentLabelSize, 'Enable', 'off');
            obj.experimentCard.startTimeField = createLabeledTextField(experimentLayout, 'Start time:', experimentLabelSize, 'Enable', 'off');
            obj.experimentCard.purposeField = createLabeledTextField(experimentLayout, 'Purpose:', experimentLabelSize, 'Enable', 'off');
            set(experimentLayout, 'Sizes', [25 25 25 25]);

            % Source card.
            sourceLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            sourceLabelSize = 60;
            obj.sourceCard.labelField = createLabeledTextField(sourceLayout, 'Label:', sourceLabelSize, 'Enable', 'off');
            set(sourceLayout, 'Sizes', [25]);

            % Epoch group card.
            epochGroupLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            epochGroupLabelSize = 60;
            obj.epochGroupCard.labelField = createLabeledTextField(epochGroupLayout, 'Label:', epochGroupLabelSize, 'Enable', 'off');
            obj.epochGroupCard.startTimeField = createLabeledTextField(epochGroupLayout, 'Start time:', epochGroupLabelSize, 'Enable', 'off');
            obj.epochGroupCard.sourceField = createLabeledTextFieldWithButton(epochGroupLayout, 'Source:', epochGroupLabelSize, @(h,d)notify(obj, 'ViewEpochGroupSource'), 'Enable', 'off');
            set(epochGroupLayout, 'Sizes', [25 25 25]);

            set(obj.cardPanel, 'Selection', 1);

            set(mainLayout, 'Sizes', [-1 -2]);

            obj.idMap = containers.Map();
        end

        function setSelectedCard(obj, index)
            set(obj.cardPanel, 'Selection', index);
        end

        function setExperimentNode(obj, name, id)
            root = obj.experimentTree.Root;
            set(root, ...
                'Name', name, ...
                'Value', id);
            root.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'experiment.png'));
            obj.idMap(id) = root;
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

        function addEpochGroupNode(obj, parentId, name, id)
            parent = obj.idMap(parentId);
            node = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', id);
            node.setIcon(fullfile(symphonyui.app.App.getIconsPath(), 'group.png'));
            obj.idMap(id) = node;
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
