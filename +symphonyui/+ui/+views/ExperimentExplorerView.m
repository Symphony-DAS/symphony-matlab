classdef ExperimentExplorerView < symphonyui.ui.View
    
    events
        BeginEpochGroup
        EndEpochGroup
        AddNote
        SelectedNode
    end
    
    properties
        toolbar
        beginEpochGroupTool
        endEpochGroupTool
        addNoteTool
        nodeTree
        nodeMap
        cardPanel
        experimentCard
        epochGroupCard
        epochCard
        notesTable
        noteField
    end
    
    methods
        
        function obj = ExperimentExplorerView(parent)
            obj = obj@symphonyui.ui.View(parent);
        end
        
        function createUi(obj)
            import symphonyui.util.*;
            import symphonyui.util.ui.*;
            
            set(obj.figureHandle, 'Name', 'Experiment Explorer');
            set(obj.figureHandle, 'Position', screenCenter(400, 400));
            
            iconsFolder = fullfile(symphonyui.app.App.rootPath, 'resources', 'icons');
            
            % Toolbar.
            obj.toolbar = uitoolbar( ...
                'Parent', obj.figureHandle);
            obj.beginEpochGroupTool = uipushtool( ...
                'Parent', obj.toolbar, ...
                'TooltipString', 'Begin Epoch Group', ...
                'ClickedCallback', @(h,d)notify(obj, 'BeginEpochGroup'));
            setIconImage(obj.beginEpochGroupTool, fullfile(iconsFolder, 'group_begin.png'));
            obj.endEpochGroupTool = uipushtool( ...
                'Parent', obj.toolbar, ...
                'TooltipString', 'End Epoch Group', ...
                'ClickedCallback', @(h,d)notify(obj, 'EndEpochGroup'));
            setIconImage(obj.endEpochGroupTool, fullfile(iconsFolder, 'group_end.png'));
            obj.addNoteTool = uipushtool( ...
                'Parent', obj.toolbar, ...
                'Separator', 'on', ...
                'TooltipString', 'Add Note...', ...
                'ClickedCallback', @(h,d)notify(obj, 'AddNote'));
            setIconImage(obj.addNoteTool, fullfile(iconsFolder, 'note.png'));
            
            mainLayout = uiextras.VBoxFlex( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            topLayout = uiextras.HBoxFlex( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.nodeTree = uiextras.jTree.Tree( ...
                'Parent', topLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'SelectionChangeFcn', @(h,d)notify(obj, 'SelectedNode'));
            obj.nodeTree.Root.setIcon(fullfile(iconsFolder, 'experiment.png'));
            obj.nodeTree.Root.Value = 'ROOT';
            
            obj.cardPanel = uix.CardPanel( ...
                'Parent', topLayout);
            
            % Experiment card.
            experimentLabelSize = 60;
            experimentLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            obj.experimentCard.nameField = createLabeledTextField(experimentLayout, 'Name:', [experimentLabelSize -1]);
            obj.experimentCard.locationField = createLabeledTextField(experimentLayout, 'Location:', [experimentLabelSize -1]);
            set(experimentLayout, 'Sizes', [25 25]);
            
            % Epoch group card.
            epochGroupLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            
            % Epoch card.
            epochLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            
            set(obj.cardPanel, 'UserData', {'Experiment', 'Epoch Group', 'Epoch'});
            set(obj.cardPanel, 'Selection', 1);
            
            set(topLayout, 'Sizes', [110 -1]);
            
            obj.nodeMap = containers.Map();
            obj.nodeMap(obj.nodeTree.Root.Value) = obj.nodeTree.Root;
            
            % Notes controls.
            notesLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.notesTable = createTable( ...
                'Parent', notesLayout, ...
                'Container', notesLayout, ...
                'Headers', {'Date', 'Text'}, ...
                'Buttons', 'off');
            obj.notesTable.getTableScrollPane.getRowHeader.setVisible(0);
            
            set(mainLayout, 'Sizes', [-1 110]);
        end
        
        function id = getRootNodeId(obj)
            id = get(obj.nodeTree.Root, 'Value');
        end
        
        function addNode(obj, parentId, name, id)
            node = uiextras.jTree.TreeNode( ...
                'Parent', obj.nodeMap(parentId), ...
                'Name', name, ...
                'Value', id);
            obj.nodeMap(id) = node;
        end
        
        function setNodeName(obj, id, name)
            node = obj.nodeMap(id);
            set(node, 'Name', name);
        end
        
        function id = getSelectedNode(obj)
            node = obj.nodeTree.SelectedNodes;
            id = get(node, 'Value'); 
        end
        
        function l = getCardList(obj)
            l = get(obj.cardPanel, 'UserData');
        end
        
        function setSelectedCard(obj, index)
            set(obj.cardPanel, 'Selection', index);
        end
        
        function setExperimentName(obj, n)
            set(obj.experimentCard.nameField, 'String', n);
        end
        
        function setExperimentLocation(obj, l)
            set(obj.experimentCard.locationField, 'String', l);
        end
        
    end
    
end

