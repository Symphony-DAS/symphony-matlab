classdef ExperimentView < symphonyui.ui.View

    events
        SelectedNode
    end

    properties (Access = private)
        experimentTree
        propertyGrid
        idMap
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Experiment');
            set(obj.figureHandle, 'Position', screenCenter(400, 400));
            
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

            obj.propertyGrid = uiextras.jide.PropertyGrid(detailLayout);

            obj.idMap = containers.Map();
            
            set(mainLayout, 'Sizes', [-1 -2]);
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
        
        function setProperties(obj, properties)
            set(obj.propertyGrid, 'Properties', properties);
        end

    end

end
