classdef Tree < hgsetget
    % Tree - Class definition for Tree
    %   The Tree object places a tree control within a figure or
    %   container.
    %
    % Syntax:
    %   nObj = uiextras.jTree.Tree
    %   nObj = uiextras.jTree.Tree('Property','Value',...)
    %
    % Tree Properties:
    %
    %   BackgroundColor - controls background color of the tree
    %
    %   DndEnabled - controls whether drag and drop is enabled on the
    %   tree
    %
    %   Enable - controls whether the tree is enabled or disabled
    %
    %   Editable - controls whether the tree node text is editable
    %
    %   FontAngle - font angle [normal|italic]
    %
    %   FontName - font name [string]
    %
    %   FontSize - font size [numeric]
    %
    %   FontWeight - font weight [normal|bold]
    %
    %   Parent - handle graphics parent for the tree, which should be
    %   a valid container including figure, uipanel, or uitab
    %
    %   Position - position of the tree within the parent container
    %
    %   RootVisible - whether the root is visible or not
    %
    %   SelectedNodes - tree nodes that are currently selected
    %
    %   SelectionType - selection mode string ('single', 'contiguous', or
    %   'discontiguous')
    %
    %   Tag - tag assigned to the tree container
    %
    %   Units - units of the tree container, used for determining the
    %   position
    %
    %   UserData - User data to store in the tree node
    %
    %   Visible - controls visibility of the control
    %
    %   ButtonUpFcn - callback when the mouse button goes up over the tree
    %
    %   ButtonDownFcn - callback when the mouse button goes down over the
    %   tree
    %
    %   MouseClickedCallback - callback when the mouse is clicked on the
    %   tree
    %
    %   MouseMotionFcn - callback while the mouse is being moved over the
    %   tree
    %
    %   NodeDraggedCallback - callback for a node being dragged. A custom
    %   callback should return a logical true when the node being dragged
    %   over is a valid drop target.
    %
    %   NodeDroppedCallback - callback for a node being dropped. A custom
    %   callback should handle the data transfer. If not specified,
    %   dragging and dropping nodes just modifies the parent of the nodes
    %   that were dragged and dropped.
    %
    %   NodeExpandedCallback - callback for a node being expanded
    %
    %   NodeCollapsedCallback - callback for a node being collapsed
    %
    %   NodeEditedCallback - callback for a node being edited
    %
    %   SelectionChangeFcn - callback for change in tree node selection
    %
    %   UIContextMenu - context menu to show when clicking anywhere
    %   within the tree control
    %
    %   Root - the root tree node
    %
    % Tree Example:
    %
    %   %% Create the figure and display the tree
    %   f = figure;
    %   t = uiextras.jTree.Tree('Parent',f,...
    %       'SelectionChangeFcn','disp(''SelectionChangeFcn triggered'')');
    %
    %   %% Create tree nodes
    %   Node1 = uiextras.jTree.TreeNode('Name','Node_1','Parent',t.Root);
    %   Node1_1 = uiextras.jTree.TreeNode('Name','Node_1_1','Parent',Node1);
    %   Node1_2 = uiextras.jTree.TreeNode('Name','Node_1_2','Parent',Node1);
    %   Node2 = uiextras.jTree.TreeNode('Name','Node_2','Parent',t.Root);
    %
    %   %% Set an icon
    %   RootIcon = which('matlabicon.gif');
    %   setIcon(Node1,RootIcon)
    %
    %   %% Move nodes around
    %   Node1_2.Parent = t;
    %
    %   %% Disable the tree
    %   t.Enable = 'off';
    %
    %   %% Enable the tree
    %   t.Enable = 'on';
    %
    % See also: uiextras.jTree.CheckboxTree, uiextras.jTree.TreeNode,
    %           uiextras.jTree.CheckboxTreeNode
    
    %   Copyright 2012-2014 The MathWorks, Inc.
    %
    % Auth/Revision:
    %   MathWorks Consulting
    %   $Author: rjackey $
    %   $Revision: 1063 $  $Date: 2015-01-15 14:23:13 -0500 (Thu, 15 Jan 2015) $
    % ---------------------------------------------------------------------
    
    % DEVELOPER NOTE: Java objects that may be used in a callback must be
    % put on the EDT to make them thread-safe in MATLAB. Otherwise, they
    % could execute along side a MATLAB command and get into a thread-lock
    % situation. Methods of the objects put on the EDT will be executed on
    % the thread-safe EDT.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties (Dependent=true, SetAccess=public, GetAccess=public)
        BackgroundColor %controls background color of the tree
        DndEnabled %controls whether drag and drop is enabled on the tree
        Enable %controls whether the tree is enabled or disabled
        Editable %controls whether the tree node text is editable
        FontAngle
        FontName
        FontSize
        FontWeight
        Parent %parent container
        Position %position of the tree within the parent container
        RootVisible %whether the root is visible or not
        SelectedNodes %tree nodes that are currently selected
        SelectionType %selection mode string
        Tag %tag assigned to the tree container
        Units %units of the tree container, used for determining the position
        UserData %User data to store in the tree node
        Visible %controls visibility of the control
    end
    
    properties (SetAccess=public, GetAccess=public)
        ButtonUpFcn %callback when the mouse button goes up over the tree
        ButtonDownFcn %callback when the mouse button goes down over the tree
        MouseClickedCallback %callback when the mouse is clicked on the tree
        MouseMotionFcn %callback while the mouse is being moved over the tree
        NodeDraggedCallback %callback for a node being dragged
        NodeDroppedCallback %callback for a node being dropped
        NodeExpandedCallback %callback for a node being expanded
        NodeCollapsedCallback %callback for a node being collapsed
        NodeEditedCallback %callback for a node being edited
        SelectionChangeFcn %callback for change in tree node selection
        UIContextMenu %context menu to show when clicking anywhere within the tree control
    end
    
    properties (SetAccess=protected, GetAccess=public)
        Root %the root tree node
    end
    
    % The tree needs to be accessible to the nodes also
    properties (SetAccess={?uiextras.jTree.Tree, ?uiextras.jTree.TreeNode},...
            GetAccess={?uiextras.jTree.Tree, ?uiextras.jTree.TreeNode})
        jTree       %Java object for tree
    end
    
    properties (SetAccess=protected, GetAccess=protected)
        hPanel %handle to the underlying panel of the tree control (internal)
        jModel %Java model for tree (internal)
        jSelModel %Java tree selection model (internal)
        jScrollPane %Java scroll pane (internal)
        jDropTarget %Java drop target (internal)
        jTransferHandler %Java transfer handler for DND (internal)
        jCellRenderer %Java cell renderer (internal)
        hJContainer %HG Java container (internal)
        IsConstructed = false; %true when the constructor is complete (internal)
        CBEnabled = false; %callbacks enabled state (internal)
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % A constructor method is a special function that creates an instance
    % of the class. Typically, constructor methods accept input arguments
    % to assign the data stored in properties and always return an
    % initialized object.
    methods
        function tObj = Tree(varargin)
            % Tree - Constructor for Tree
            % -------------------------------------------------------------------------
            % Abstract: Constructs a new Tree object.  No special
            % action is taken.
            %
            % Syntax:
            %           tObj = uiextras.jTree.Tree('p1',v1,...)
            %
            % Inputs:
            %           Property-value pairs
            %
            % Outputs:
            %           tObj - uiextras.jTree.Tree object
            %
            % Examples:
            %           hFig = figure;
            %           tObj = Tree('Parent',hFig)
            %
            
            % Add the custom java paths
            uiextras.jTree.loadJavaCustomizations();
            
            %----- Parse Inputs -----%
            p = inputParser;
            p.KeepUnmatched = true;
            
            % Define defaults and requirements for each parameter
            p.addParamValue('FontAngle','normal');
            p.addParamValue('FontName','MS Sans Serif');
            p.addParamValue('FontSize',10);
            p.addParamValue('FontWeight','normal');
            p.addParamValue('Parent',[]);
            p.addParamValue('Units','normalized');
            p.addParamValue('Position',[0 0 1 1]);
            p.parse(varargin{:});
            
            %----- Create Graphics -----%
            
            % Create the java tree
            createTree(tObj);
            
            % Create the container for the tree
            createTreeContainer(tObj,p.Results.Parent)
            
            % Customize the tree
            createTreeCustomizations(tObj);
            
            % Use the custom renderer
            tObj.jCellRenderer = javaObjectEDT('UIExtrasTree.TreeCellRenderer');
            setCellRenderer(tObj.jTree, tObj.jCellRenderer);
            
            % Add properties to the java object for MATLAB data
            hTree = handle(tObj.jTree);
            schema.prop(hTree,'Tree','MATLAB array');
            schema.prop(hTree,'UserData','MATLAB array');
            
            % Add a reference to this object
            hTree.Tree = tObj;
            
            % Refresh the tree
            reload(tObj, tObj.Root);
            
            %----- Set Remaining Inputs -----%
            
            % Set user-supplied property values
            PVToSet = rmfield(p.Results,{'Parent','Position','Units'});
            set(tObj,PVToSet);
            
            % Set remaining user-supplied property values
            if ~isempty(fieldnames(p.Unmatched))
                set(tObj,p.Unmatched);
            end
            
            % Indicate construction is complete
            tObj.IsConstructed = true;
            tObj.CBEnabled = true;
            
        end
    end %methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Destructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function delete(tObj)
            tObj.CBEnabled = false;
            delete(tObj.Root);
            % Remove references to the java objects
            tObj.jTree = [];
            tObj.jModel = [];
            tObj.jSelModel = [];
            tObj.jScrollPane = [];
            tObj.jDropTarget = [];
            tObj.jTransferHandler = [];
            tObj.hJContainer = [];
            tObj.jScrollPane = [];
            tObj.jScrollPane = [];
            tObj.jScrollPane = [];
            if ishandle(tObj.hPanel)
                delete(tObj.hPanel);
            end
        end
    end %methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Public Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods are functions that implement the operations performed on
    % objects of a class. They may be stored within the classdef file or as
    % separate files in a @classname folder.
    methods
        
        function refresh(tObj,nObj)
            % refresh - Reload the specified tree node
            % -------------------------------------------------------------------------
            % Abstract: Reload the specified tree node, or the root
            %
            % Syntax:
            %           tObj.refresh(nObj) - refreshes the specified node
            %           tObj.refresh() - refreshes the root
            %
            % Inputs:
            %           tObj - Tree object
            %           nObj - TreeNode object
            %
            % Outputs:
            %           none
            %
            tObj.CBEnabled = false;
            if nargin<2
                nObj = tObj.Root;
            end
            reload(tObj,nObj);
            tObj.CBEnabled = true;
        end
        
        function reload(tObj,nObj)
            if ~isempty([tObj.jModel]) && ishandle(nObj.jNode)
                tObj.CBEnabled = false;
                tObj.jModel.reload(nObj.jNode);
                tObj.CBEnabled = true;
            end
        end
        
        function nodeChanged(tObj,nObj)
            if ~isempty([tObj.jModel]) && ishandle(nObj.jNode)
                tObj.CBEnabled = false;
                tObj.jModel.nodeChanged(nObj.jNode);
                tObj.CBEnabled = true;
            end
        end
        
        function insertNode(tObj,nObj,pObj,idx)
            tObj.CBEnabled = false;
            tObj.jModel.insertNodeInto(nObj.jNode, pObj.jNode, idx-1);
            % If this is the first and only child, we need to reload the
            % tree node so it renders correctly
            if all(pObj.Children == nObj)
                tObj.jModel.reload(pObj.jNode);
            end
            tObj.CBEnabled = true;
        end
        
        function removeNode(tObj,nObj,pObj)
            if ~isempty([tObj.jModel]) && ishandle(nObj.jNode)
                tObj.CBEnabled = false;
                tObj.jModel.removeNodeFromParent(nObj.jNode);
                % If all children were removed, reload the node
                %if isempty(pObj.Children) && ~isempty(pObj.Tree)
                %    tObj.jModel.reload(pObj.jNode);
                %end
                tObj.CBEnabled = true;
            end
        end

        function collapseNode(tObj,nObj)
            % collapseNode - Collapse a TreeNode within the tree
            % -------------------------------------------------------------------------
            % Abstract: Collapse the specified tree node
            %
            % Syntax:
            %           tObj.collapseNode(nObj)
            %
            % Inputs:
            %           tObj - Tree object
            %           nObj - TreeNode object
            %
            % Outputs:
            %           none
            %
            tObj.CBEnabled = false;
            collapsePath(tObj.jTree, nObj.jNode.getTreePath());
            tObj.CBEnabled = true;
        end
        
        function expandNode(tObj,nObj)
            % expandNode - Expand a TreeNode within the tree
            % -------------------------------------------------------------------------
            % Abstract: Expand the specified tree node
            %
            % Syntax:
            %           tObj.expandNode(nObj)
            %
            % Inputs:
            %           tObj - Tree object
            %           nObj - TreeNode object
            %
            % Outputs:
            %           none
            %
            tObj.CBEnabled = false;
            expandPath(tObj.jTree, nObj.jNode.getTreePath());
            tObj.CBEnabled = true;
        end
        
        function s = getJavaObjects(tObj)
            % getJavaObjects - Returns underlying java objects
            % -------------------------------------------------------------------------
            % Abstract: (For debugging use only) Returns the underlying
            % Java objects.
            %
            % Syntax:
            %           s = getJavaObjects(tObj)
            %
            % Inputs:
            %           tObj - Tree object
            %
            % Outputs:
            %           s - struct of Java objects
            %
            s = struct(...
                'hPanel',tObj.hPanel,...
                'jTree',tObj.jTree,...
                'jModel',tObj.jModel,...
                'jSelModel',tObj.jSelModel,...
                'jScrollPane',tObj.jScrollPane,...
                'jDropTarget',tObj.jDropTarget,...
                'jTransferHandler',tObj.jTransferHandler,...
                'hJContainer',tObj.hJContainer);
        end
        
    end %public methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Protected Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = protected)
        
        function createTree(tObj)
            
            % Create the root node
            tObj.Root = uiextras.jTree.TreeNode('Name','Root','Tree',tObj);
            
            % Create the tree
            %nObj.jNode = handle(javaObjectEDT('UIExtrasTree.TreeNode'));
            if isempty(tObj.Root)
                tObj.jTree = javaObjectEDT('javax.swing.JTree');
            else
                tObj.jTree = javaObjectEDT('javax.swing.JTree',tObj.Root.jNode);
            end
            
            % Store the model
            tObj.jModel = tObj.jTree.getModel();
            javaObjectEDT(tObj.jModel); % Put it on the EDT
            
            % Store the selection model
            tObj.jSelModel = tObj.jTree.getSelectionModel();
            javaObjectEDT(tObj.jSelModel); % Put it on the EDT
            
        end
        
        function createTreeContainer(tObj,hParent)
            % Create the container(s) for the tree
            
            % If no parent, create a figure
            if isempty(hParent)
                hParent = figure();
            end
            
            % Create the base panel
            tObj.hPanel = uipanel(...
                'Parent',double(hParent),...
                'BorderType','none',...
                'Clipping','on',...
                'DeleteFcn',@(src,e)delete(tObj),...
                'Visible','on',...
                'UserData',tObj);
            
            % Create a scroll pane
            tObj.jScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',tObj.jTree);
            [~,tObj.hJContainer] = javacomponent(tObj.jScrollPane,[0 0 100 100],tObj.hPanel);
            set(tObj.hJContainer,'Units','normalized','Position',[0 0 1 1])
            
        end
        
        function createTreeCustomizations(tObj)
            
            % Default to single selection
            tObj.SelectionType = 'single';
            
            % Set the java tree callbacks
            CbProps = handle(tObj.jTree,'CallbackProperties');
            set(CbProps,'MouseClickedCallback',@(src,e)onMouseClick(tObj,e))
            set(CbProps,'MousePressedCallback',@(src,e)onButtonDown(tObj,e))
            set(CbProps,'MouseReleasedCallback',@(src,e)onButtonUp(tObj,e))
            set(CbProps,'TreeWillExpandCallback',@(src,e)onExpand(tObj,e))
            %set(CbProps,'TreeExpandedCallback',@(src,e)onExpand(tObj,e))
            %set(CbProps,'TreeWillCollapseCallback',@(src,e)onCollapse(tObj,e))
            set(CbProps,'TreeCollapsedCallback',@(src,e)onCollapse(tObj,e))
            %set(CbProps,'MouseDraggedCallback',@(src,e)onMouseDrag(tObj,e))
            set(CbProps,'MouseMovedCallback',@(src,e)onMouseMotion(tObj,e))
            set(CbProps,'ValueChangedCallback',@(src,e)onNodeSelection(tObj,e))
            
            % Set up editability callback
            CbProps = handle(tObj.jModel,'CallbackProperties'); 
            set(CbProps,'TreeNodesChangedCallback',@(src,e)onNodeEdit(tObj,e))
            
            % Set up drag and drop
            tObj.jDropTarget = javaObjectEDT('java.awt.dnd.DropTarget');
            tObj.jTree.setDropTarget(tObj.jDropTarget);
            tObj.jTransferHandler = javaObjectEDT('UIExtrasTree.TreeTransferHandler');
            tObj.jTree.setTransferHandler(tObj.jTransferHandler);
            
            % Set up drop target callbacks
            CbProps = handle(tObj.jDropTarget,'CallbackProperties'); 
            set(CbProps,'DropCallback',@(src,e)onNodeDND(tObj,e));
            set(CbProps,'DragOverCallback',@(src,e)onNodeDND(tObj,e));
            
            % Allow tooltips
            jTTipMgr = javaMethodEDT('sharedInstance','javax.swing.ToolTipManager');
            jTTipMgr.registerComponent(tObj.jTree);
            
            % Set auto row height (in case font changes)
            tObj.jTree.setRowHeight(-1);
            
        end
        
        function tf = callbacksEnabled(tObj)
            % Check whether callbacks from Java should trigger a MATLAB
            % callback
            tf = isvalid(tObj) && tObj.CBEnabled;
            
        end
        
        function nObj = getNodeFromMouseEvent(tObj,e)
            
            % Get the click position
            x = e.getX;
            y = e.getY;
            
            % Was a tree node clicked?
            treePath = tObj.jTree.getPathForLocation(x,y);
            if isempty(treePath)
                nObj  = uiextras.jTree.TreeNode.empty(0,1);
            else
                nObj = get(treePath.getLastPathComponent,'TreeNode');
            end
            
        end
        
        
        function onExpand(tObj,e)
            % Occurs when a node is expanded
            
            % Is there a custom NodeExpandedCallback?
            if callbacksEnabled(tObj) && ~isempty(tObj.NodeExpandedCallback)
                
                % Get the tree node that was expanded
                CurrentNode = get(e.getPath.getLastPathComponent,'TreeNode');
                
                % Call the custom callback
                e1 = struct('Nodes',CurrentNode);
                hgfeval(tObj.NodeExpandedCallback,tObj,e1);
                
            end %if ~isempty(tObj.NodeExpandedCallback)
            
        end %function onExpand
        
        
        function onCollapse(tObj,e)
            % Occurs when a node is collapsed
            
            % Is there a custom NodeCollapsedCallback?
            if callbacksEnabled(tObj) && ~isempty(tObj.NodeCollapsedCallback)
                
                % Get the tree node that was collapsed
                CurrentNode = get(e.getPath.getLastPathComponent,'TreeNode');
                
                % Call the custom callback
                e1 = struct('Nodes',CurrentNode);
                hgfeval(tObj.NodeCollapsedCallback,tObj,e1);
                
            end %if ~isempty(tObj.NodeCollapsedCallback)
            
        end %function onCollapse
        
        
        function onMouseClick(tObj,e)
            % Occurs when the mouse is clicked within the pane
            
            if callbacksEnabled(tObj)
                
                % Was a tree node clicked?
                nObj = getNodeFromMouseEvent(tObj,e);
                
                % Get the position clicked
                x = e.getX;
                y = e.getY;
                
                if e.isMetaDown %Right-click
                    
                    % Default menu to use
                    CMenu = tObj.UIContextMenu;
                    if ~isempty(nObj)
                        
                        % If the node was not previously selected, do it
                        if ~any(tObj.SelectedNodes == nObj)
                            tObj.SelectedNodes = nObj;
                        end
                        
                        % Get the custom context menus for selected nodes
                        NodeCMenus = [tObj.SelectedNodes.UIContextMenu];
                        
                        % See if there is a common context menu
                        ThisCMenu = unique(NodeCMenus);
                        
                        % Is there a common context menu across all
                        % selected nodes?
                        if ~isempty(NodeCMenus) &&...
                                numel(NodeCMenus) == numel(tObj.SelectedNodes) &&...
                                all(NodeCMenus(1) == NodeCMenus)
                            
                            % Use the custom context menu
                            CMenu = ThisCMenu;
                        end
                        
                    end
                    
                    % Display the context menu
                    if ~isempty(CMenu)
                        tPos = getpixelposition(tObj.hJContainer,true);
                        mPos = [x+tPos(1) tPos(2)+tPos(4)-y+tObj.jScrollPane.getVerticalScrollBar().getValue()];
                        set(CMenu,'Position',mPos,'Visible','on');
                    end
                    
                elseif ~isempty(tObj.MouseClickedCallback)
                    % Do the following for a custom MouseClickedCallback
                    
                    % Call the custom callback
                    e1 = struct(...
                        'Position',[x,y],...
                        'Nodes',nObj);
                    hgfeval(tObj.MouseClickedCallback,tObj,e1);
                    
                end %if e.isMetaDown
                
            end %if callbacksEnabled(tObj)
            
        end %function onMouseClick
        
        
        function onButtonDown(tObj,e)
            % Occurs when the mouse button goes down within the pane
            
            % Is there a custom ButtonDownFcn?
            if callbacksEnabled(tObj) && ~isempty(tObj.ButtonDownFcn)
                
                % Get the click position
                x = e.getX;
                y = e.getY;
                
                % Was a tree node clicked?
                nObj = getNodeFromMouseEvent(tObj,e);
                
                % Call the custom callback
                e1 = struct(...
                    'Position',[x,y],...
                    'Nodes',nObj);
                hgfeval(tObj.ButtonDownFcn,tObj,e1);
                
            end %if ~isempty(tObj.ButtonDownFcn)
            
        end %function onButtonDown
        
        function onButtonUp(tObj,e)
            % Occurs when the mouse button goes up within the pane
            
            % Is there a custom ButtonUpFcn?
            if callbacksEnabled(tObj) && ~isempty(tObj.ButtonUpFcn)
                
                % Get the click position
                x = e.getX;
                y = e.getY;
                
                % Was a tree node clicked?
                nObj = getNodeFromMouseEvent(tObj,e);
                
                % Call the custom callback
                e1 = struct(...
                    'Position',[x,y],...
                    'Nodes',nObj);
                hgfeval(tObj.ButtonUpFcn,tObj,e1);
                
            end %if ~isempty(tObj.ButtonUpFcn)
            
        end %function onButtonUp
        
        
        function onMouseMotion(tObj,e)
            % Occurs when the mouse moves within the pane
            
            % Is there a custom MouseMotionFcn?
            if callbacksEnabled(tObj) && ~isempty(tObj.MouseMotionFcn)
                
                % Get the click position
                x = e.getX;
                y = e.getY;
                
                % Was a tree node clicked?
                nObj = getNodeFromMouseEvent(tObj,e);
                
                % Call the custom callback
                e1 = struct(...
                    'Position',[x,y],...
                    'Nodes',nObj);
                hgfeval(tObj.MouseMotionFcn,tObj,e1);
                
            end %if ~isempty(tObj.MouseMotionFcn)
            
        end %function onMouseMotion
        
        
        function onNodeSelection(tObj,e)
            % Occurs when the selection of tree paths (nodes) changes
            
            % Has the constructor completed running?
            % Has a treeCallback been specified?
            if callbacksEnabled(tObj) && ~isempty(tObj.SelectionChangeFcn)
                
                % Figure out what nodes were added or removed to/from the
                % selection
                p = e.getPaths;
                AddedNodes = uiextras.jTree.TreeNode.empty(0,1);
                RemovedNodes = uiextras.jTree.TreeNode.empty(0,1);
                for idx = 1:numel(p)
                    nObj = get(p(idx).getLastPathComponent(),'TreeNode');
                    if isvalid(nObj)
                        if e.isAddedPath(idx-1); %zero-based index
                            AddedNodes(end+1) = nObj; %#ok<AGROW>
                        else
                            RemovedNodes(end+1) = nObj; %#ok<AGROW>
                        end
                    end
                end
                
                % Prepare eventdata for the callback
                e1 = struct(...
                    'Nodes', tObj.SelectedNodes,...
                    'AddedNodes',AddedNodes,...
                    'RemovedNodes',RemovedNodes);
                
                % Call the treeCallback
                hgfeval(tObj.SelectionChangeFcn,tObj,e1);
            end
            
        end %function onNodeSelection
        
        function onNodeEdit(tObj,e)
            % Occurs when a node is edited
            
            % Is there a custom NodeEditedCallback?
            if callbacksEnabled(tObj) && ~isempty(tObj.NodeEditedCallback)
                
                % Get the tree nodes that were edited
                c = e.getChildren;
                EditedNode = uiextras.jTree.TreeNode.empty(0,1);
                for idx = 1:numel(c)
                    EditedNode = get(c(idx),'TreeNode');
                end
                
                % Get the parent node of the edit
                ParentNode = get(e.getTreePath.getLastPathComponent,'TreeNode');
                
                % Call the custom callback
                e1 = struct(...
                    'Nodes',EditedNode,...
                    'ParentNode',ParentNode);
                hgfeval(tObj.NodeEditedCallback,tObj,e1);
                
            end %if ~isempty(tObj.NodeEditedCallback)
            
        end %function onNodeEdit
        
        function onNodeDND(tObj,e)
            % Occurs when a node is dragged or dropped on the tree
            
            % The Transferable object is available only during drag
            persistent Transferable
            
            if callbacksEnabled(tObj)
                
                try %#ok<TRYNC>
                    % The Transferable object is available only during drag
                    Transferable = e.getTransferable;
                    javaObjectEDT(Transferable); % Put it on the EDT
                end
                
                % Catch errors if unsupported items are dragged onto the
                % tree
                try
                    DataFlavors = Transferable.getTransferDataFlavors;
                    TransferData = Transferable.getTransferData(DataFlavors(1));
                catch %#ok<CTCH>
                    TransferData = [];
                end
                
                % Get the source node(s)
                SourceNode = uiextras.jTree.TreeNode.empty(0,1);
                for idx = 1:numel(TransferData)
                    SourceNode(idx) = get(TransferData(idx),'TreeNode');
                end
                
                % Filter descendant source nodes. If dragged nodes are
                % descendants of other dragged nodes, they should be
                % excluded so the hierarchy is maintained.
                idxRemove = isDescendant(SourceNode,SourceNode);
                SourceNode(idxRemove) = [];
                
                % Get the target node
                Loc = e.getLocation();
                treePath = tObj.jTree.getPathForLocation(...
                    Loc.getX + tObj.jScrollPane.getHorizontalScrollBar().getValue(), Loc.getY + tObj.jScrollPane.getVerticalScrollBar().getValue());
                if isempty(treePath)
                    % If no target node, the target is the background of
                    % the tree. Assume the root is the intended target.
                    TargetNode = tObj.Root;
                else
                    TargetNode = get(treePath.getLastPathComponent,'TreeNode');
                end
                
                % Get the operation type
                switch e.getDropAction()
                    case 0
                        DropAction = 'link';
                    case 1
                        DropAction = 'copy';
                    case 2
                        DropAction = 'move';
                    otherwise
                        DropAction = '';
                end
                
                % Create event data for user callback
                e1 = struct(...
                    'Source',SourceNode,...
                    'Target',TargetNode,...
                    'DropAction',DropAction);
                % Check if the source/target are valid
                % Check the node is not dropped onto itself
                % Check a node may not be dropped onto a descendant
                TargetOk = ~isempty(TargetNode) &&...
                    ~isempty(SourceNode) && ...
                    ~any(SourceNode==TargetNode) && ...
                    ~any(isDescendant(SourceNode,TargetNode));
                
                % A move operation may not drop a node onto its parent
                if TargetOk && strcmp(DropAction,'move')
                    TargetOk = ~any([SourceNode.Parent]==TargetNode);
                end
                
                % Is this the drag or the drop event?
                if e.isa('java.awt.dnd.DropTargetDragEvent')
                    %%%%%%%%%%%%%%%%%%%
                    % Drag Event
                    %%%%%%%%%%%%%%%%%%%
                    
                    % Is there a custom NodeDraggedCallback to call?
                    if TargetOk && ~isempty(tObj.NodeDraggedCallback)
                        TargetOk = hgfeval(tObj.NodeDraggedCallback,tObj,e1);
                    end
                    
                    % Is this a valid target?
                    if TargetOk
                        e.acceptDrag(e.getDropAction);
                    else
                        e.rejectDrag();
                    end
                    
                elseif e.isa('java.awt.dnd.DropTargetDropEvent')
                    %%%%%%%%%%%%%%%%%%%
                    % Drop Event
                    %%%%%%%%%%%%%%%%%%%
                    
                    % Is there a custom NodeDraggedCallback to call?
                    if TargetOk && ~isempty(tObj.NodeDraggedCallback)
                        TargetOk = hgfeval(tObj.NodeDraggedCallback,tObj,e1);
                    end
                    
                    % Should we process the drop?
                    if TargetOk
                        
                        % Is there a custom NodeDroppedCallback to call?
                        if ~isempty(tObj.NodeDroppedCallback)
                            hgfeval(tObj.NodeDroppedCallback,tObj,e1);
                        else
                            % Just move the node to the new destination, and expand
                            switch DropAction
                                case 'copy'
                                    NewSourceNode = copy(SourceNode,TargetNode);
                                    expand(TargetNode)
                                    expand(SourceNode)
                                    expand(NewSourceNode)
                                case 'move'
                                    set(SourceNode,'Parent',TargetNode)
                                    expand(TargetNode)
                                    expand(SourceNode)
                                otherwise
                                    % Do nothing
                            end
                        end
                        
                    end
                    
                    % Tell Java the drop is complete
                    e.dropComplete(true)
                    
                end
                
            end %if callbacksEnabled(tObj)
            
        end %function onNodeDND
        
    end %private methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get and Set Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get and set methods customize the behavior that occurs when code gets
    % or sets a property value.
    methods
        
        function value = get.BackgroundColor(tObj)
            jColor = tObj.jTree.getBackground();
            value = [jColor.getRed jColor.getGreen jColor.getBlue]/255;
        end
        function set.BackgroundColor(tObj,value)
            validateattributes(value,{'double'},{'size',[1 3],'>=',0,'<=',1});
            tObj.jTree.setBackground(java.awt.Color(value(1),value(2),value(3)));
            tObj.jCellRenderer.setBackgroundNonSelectionColor(...
                java.awt.Color(value(1),value(2),value(3)));
            tObj.jTree.repaint();
        end
        
        % CBEnabled
        function set.CBEnabled(tObj,value)
            drawnow;
            tObj.CBEnabled = value;
            drawnow;
        end
        
        % DndEnabled
        function value = get.DndEnabled(tObj)
            value = tObj.jTree.getDragEnabled();
        end
        function set.DndEnabled(tObj,value)
            if ischar(value)
                value = strcmp(value,'on');
            end
            validateattributes(value,{'numeric','logical'},{'scalar'});
            tObj.jTree.setDragEnabled(logical(value));
        end
        
        % Editable
        function value = get.Editable(tObj)
            value = get(tObj.jTree,'Editable');
        end
        function set.Editable(tObj,value)
            if ischar(value)
                value = strcmp(value,'on');
            end
            validateattributes(value,{'numeric','logical'},{'scalar'});
            tObj.jTree.setEditable(logical(value));
        end
        
        % Enable
        function value = get.Enable(tObj)
            value = get(tObj.jTree,'Enabled');
        end
        function set.Enable(tObj,value)
            if ischar(value)
                value = strcmp(value,'on');
            end
            validateattributes(value,{'numeric','logical'},{'scalar'});
            value = logical(value);
            setEnabled(tObj.jTree,value);
            sb1 = javaObjectEDT(get(tObj.jScrollPane,'VerticalScrollBar'));
            sb2 = javaObjectEDT(get(tObj.jScrollPane,'HorizontalScrollBar'));
            setEnabled(sb1,value);
            setEnabled(sb2,value);
        end
        
        
        
        
        % FontAngle
        function value = get.FontAngle(tObj)
            
            switch tObj.jTree.getFont().isItalic()
                case true
                    value = 'italic';
                case false
                    value = 'normal';
            end
            
        end % get.FontAngle
        
        function set.FontAngle(tObj, value)
            
            jTable = tObj.jTree;
            jFont = jTable.getFont();
            switch value
                case 'normal'
                    jStyle = java.awt.Font.BOLD * jFont.isBold();
                case 'italic'
                    jStyle = java.awt.Font.BOLD * jFont.isBold() + ...
                        java.awt.Font.ITALIC;
                case 'oblique'
                    error('uiextras:Tree:InvalidArgument', ...
                        'Value ''%s'' is not supported for property ''%s''.', ...
                        value, 'FontAngle')
                otherwise
                    error('uiextras:Tree:InvalidArgument', ...
                        'Property ''FontAngle'' must be %s.', ...
                        '''normal'' or ''italic''')
            end
            jTable.setFont(javax.swing.plaf.FontUIResource(...
                jFont.getName(), jStyle, jFont.getSize()));
            
        end % set.FontAngle
        
        
        % FontName
        function value = get.FontName(tObj)
            
            value = char(tObj.jTree.getFont().getName());
            
        end % get.FontName
        
        function set.FontName(tObj, value)
            
            jTable = tObj.jTree;
            jFont = jTable.getFont();
            jTable.setFont(javax.swing.plaf.FontUIResource(...
                value, jFont.getStyle(), jFont.getSize()));
            
        end % set.FontName
        
        
        % FontSize
        function value = get.FontSize(tObj)
            
            value = tObj.jTree.getFont().getSize();
            
            % Convert value from pixels to points
            %http://stackoverflow.com/questions/6257784/java-font-size-vs-html-font-size
            % Java font is in pixels, and assumes 72dpi. Windows is
            % typically 96 and up, depending on display settings.
            dpi = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
            value = (value * 72 / dpi);
            
        end % get.FontSize
        
        function set.FontSize(tObj, value)
            
            % Get the current font
            jFont = tObj.jTree.getFont();
            
            % Convert value from points to pixels
            dpi = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
            value = round(value * dpi / 72);
            
            % Create a new Java font
            jFont = javax.swing.plaf.FontUIResource(jFont.getName(),...
                jFont.getStyle(), value);
            
            % Set the font size (in pixels)
            tObj.jTree.setFont(jFont);
            
        end % set.FontSize
        
        
        %FontWeight
        function value = get.FontWeight(tObj)
            
            switch tObj.jTree.getFont().isBold()
                case true
                    value = 'bold';
                case false
                    value = 'normal';
            end
            
        end % get.FontWeight
        
        function set.FontWeight(tObj, value)
            
            jTable = tObj.jTree;
            jFont = jTable.getFont();
            switch value
                case 'normal'
                    jStyle = jFont.isItalic() * java.awt.Font.ITALIC;
                case 'bold'
                    jStyle = jFont.isItalic() * java.awt.Font.ITALIC + ...
                        java.awt.Font.BOLD;
                case {'light','demi'}
                    error('uiextras:Tree:InvalidArgument', ...
                        'Value ''%s'' is not supported for property ''%s''.', ...
                        value, 'FontWeight')
                otherwise
                    error('uiextras:Tree:InvalidArgument', ...
                        'Property ''FontWeight'' must be %s.', ...
                        '''normal'' or ''bold''')
            end
            jTable.setFont(javax.swing.plaf.FontUIResource(...
                jFont.getName(), jStyle, jFont.getSize()));
            
        end % set.FontWeight
        
        
        % Parent
        function value = get.Parent(tObj)
            value = get(tObj.hPanel,'Parent');
        end
        function set.Parent(tObj,value)
            % Set the property in the HG panel
            set(tObj.hPanel,'Parent',double(value))
        end
        
        % Position
        function value = get.Position(tObj)
            value = get(tObj.hPanel,'Position');
        end
        function set.Position(tObj,value)
            % Set the property in the HG panel
            set(tObj.hPanel,'Position',value)
        end
        
        % RootVisible
        function value = get.RootVisible(tObj)
            value = get(tObj.jTree,'rootVisible');
        end
        function set.RootVisible(tObj,value)
            if ischar(value)
                value = strcmp(value,'on');
            end
            validateattributes(value,{'numeric','logical'},{'scalar'});
            value = logical(value);
            tObj.jTree.setRootVisible(value); %show/hide root
            tObj.jTree.setShowsRootHandles(~value); %hide/show top level handles
        end
        
        % SelectedNodes
        function value = get.SelectedNodes(tObj)
            value = uiextras.jTree.TreeNode.empty(0,1);
            srcPaths = tObj.jTree.getSelectionPaths();
            for idx = 1:numel(srcPaths)
                value(idx) = get(srcPaths(idx).getLastPathComponent,'TreeNode');
            end
        end
        function set.SelectedNodes(tObj,value)
            if isempty(value)
                if ~isempty(tObj.jTree.getSelectionPath)
                    tObj.CBEnabled = false;
                    tObj.jTree.setSelectionPath([])
                    tObj.CBEnabled = true;
                end
            elseif isa(value,'uiextras.jTree.TreeNode')
                if isscalar(value)
                    tObj.CBEnabled = false;
                    tObj.jTree.setSelectionPath(value.jNode.getTreePath());
                    tObj.CBEnabled = true;
                else
                    for idx = numel(value):-1:1 %preallocate by reversing
                        path(idx) = value(idx).jNode.getTreePath();
                    end
                    tObj.CBEnabled = false;
                    tObj.jTree.setSelectionPaths(path);
                    tObj.CBEnabled = true;
                end
            else
                error('Expected TreeNode or empty array');
            end
        end
        
        % SelectionType
        function value = get.SelectionType(tObj)
            value = tObj.jSelModel.getSelectionMode();
            switch value
                case 1
                    value = 'single';
                case 2
                    value = 'contiguous';
                case 4
                    value = 'discontiguous';
            end
        end
        function set.SelectionType(tObj,value)
            value = validatestring(value,{'single','contiguous','discontiguous'});
            switch value
                case 'single'
                    mode = tObj.jSelModel.SINGLE_TREE_SELECTION;
                case 'contiguous'
                    mode = tObj.jSelModel.CONTIGUOUS_TREE_SELECTION;
                case 'discontiguous'
                    mode = tObj.jSelModel.DISCONTIGUOUS_TREE_SELECTION;
            end
            tObj.CBEnabled = false;
            tObj.jSelModel.setSelectionMode(mode);
            tObj.CBEnabled = true;
        end
        
        % Tag
        function value = get.Tag(tObj)
            value = get(tObj.hPanel,'Tag');
        end
        function set.Tag(tObj,value)
            % Set the property in the HG panel
            set(tObj.hPanel,'Tag',value)
        end
        
        % UserData
        function value = get.UserData(tObj)
            value = get(tObj.jTree,'UserData');
        end
        function set.UserData(tObj,value)
            set(tObj.jTree,'UserData',value);
        end
        
        % Units
        function value = get.Units(tObj)
            value = get(tObj.hPanel,'Units');
        end
        function set.Units(tObj,value)
            % Set the property in the HG panel
            set(tObj.hPanel,'Units',value)
        end
        
        % Visible
        function value = get.Visible(tObj)
            value = get(tObj.jTree,'Visible');
        end
        function set.Visible(tObj,value)
            if ischar(value)
                value = strcmp(value,'on');
            end
            validateattributes(value,{'numeric','logical'},{'scalar'});
            tObj.jTree.setVisible(logical(value));
        end
        
        % UIContextMenu
        function set.UIContextMenu(tObj,value)
            if numel(value)>1 || ~ishghandle(value)
                error('Expected UIContextMenu handle')
            end
            tObj.UIContextMenu = value;
        end
        
    end %get/set methods
    
end %classdef
