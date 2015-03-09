classdef ExperimentView < symphonyui.ui.View
    
    events
        SelectedNode
    end
    
    properties
        nodeTree
    end
    
    methods
        
        function obj = ExperimentView(parent)
            obj = obj@symphonyui.ui.View(parent);
        end
        
        function createUI(obj)
            import symphonyui.util.*;
            import symphonyui.util.ui.*;
            
            set(obj.figureHandle, 'Name', 'Experiment');
            set(obj.figureHandle, 'Position', screenCenter(467, 356));
            
            mainLayout = uiextras.HBoxFlex( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            masterLayout = uiextras.VBox( ...
                'Parent', mainLayout);
            
            obj.nodeTree = uiextras.jTree.Tree( ...
                'Parent', masterLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'SelectionChangeFcn', @(h,d)notify(obj, 'SelectedNode'));
            
            iconsFolder = fullfile(symphonyui.app.App.rootPath, 'resources', 'icons');
            
            setIcon(obj.nodeTree.Root, fullfile(iconsFolder, 'experiment.png'));
            obj.nodeTree.Root.Name = 'Experiment';
            
            node = uiextras.jTree.TreeNode( ...
                'Name', 'Epoch Group', ...
                'Parent', obj.nodeTree.Root);
            node.setIcon(fullfile(iconsFolder, 'group.png'));
            
            node1 = uiextras.jTree.TreeNode( ...
                'Name', 'Epoch', ...
                'Parent', node);
            node1.setIcon(fullfile(iconsFolder, 'epoch.png'));
            
            detailLayout = uiextras.VBox( ...
                'Parent', mainLayout);
        end
        
        function n = getSelectedNode(obj)
            n = obj.nodeTree.SelectedNodes;
        end
        
        function setSelectedCard(obj, c)
            
        end
        
    end
    
end

