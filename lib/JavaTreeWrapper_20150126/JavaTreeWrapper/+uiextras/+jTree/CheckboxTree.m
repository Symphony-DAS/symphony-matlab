classdef CheckboxTree < uiextras.jTree.Tree
    % CheckboxTree - Class definition for CheckboxTree
    %   The CheckboxTree object places a checkbox tree control within a
    %   figure or container.
    %
    % Syntax:
    %           tObj = uiextras.jTree.CheckboxTree
    %           tObj = uiextras.jTree.CheckboxTree('Property','Value',...)
    %
    %   The CheckboxTree contains all properties and methods of the
    %   <a href="matlab:doc uiextras.jTree.Tree">uiextras.jTree.Tree</a>, plus the following:
    %
    % CheckboxTree Properties:
    %
    %   CheckboxClickedCallback - callback when a checkbox value is changed
    %
    %   ClickInCheckBoxOnly - if false, clicking on the node's label also
    %   toggles the checkbox value, instead of selecting the node
    %
    %   DigIn - controls whether checkbox selection of a branch also checks
    %   all children
    %
    %   CheckedNodes - tree nodes that are currently checked. In DigIn
    %   mode, this will not contain the children of fully selected
    %   branches. (read-only)
    %
    %
    % CheckboxTree Example:
    %
    %   %% Create the figure and display the tree
    %   f = figure;
    %   t = CheckboxTree('Parent',f,...
    %       'SelectionChangeFcn','disp(''SelectionChangeFcn triggered'')',...
    %       'MultiSelect','on');
    %
    %   %% Create tree nodes
    %   Node1 = uiextras.jTree.CheckboxTreeNode('Name','Node_1','Parent',t.Root);
    %   Node1_1 = uiextras.jTree.CheckboxTreeNode('Name','Node_1_1','Parent',Node1);
    %   Node1_2 = uiextras.jTree.CheckboxTreeNode('Name','Node_1_2','Parent',Node1);
    %   Node2 = uiextras.jTree.CheckboxTreeNode('Name','Node_2','Parent',t.Root);
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
    % See also: uiextras.jTree.Tree, uiextras.jTree.TreeNode,
    %           uiextras.jTree.CheckboxTreeNode
    
    %   Copyright 2012-2014 The MathWorks, Inc.
    %
    % Auth/Revision:
    %   MathWorks Consulting
    %   $Author: rjackey $
    %   $Revision: 109 $  $Date: 2014-09-30 16:42:51 -0400 (Tue, 30 Sep 2014) $
    % ---------------------------------------------------------------------
    
    % DEVELOPER NOTE: Java objects that may be used in a callback must be
    % put on the EDT to make them thread-safe in MATLAB. Otherwise, they
    % could execute along side a MATLAB command and get into a thread-lock
    % situation. Methods of the objects put on the EDT will be executed on
    % the thread-safe EDT.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties (SetAccess=public, GetAccess=public)
        CheckboxClickedCallback %callback when a checkbox value is changed
    end
    
    properties (Dependent=true, SetAccess=public, GetAccess=public)
        ClickInCheckBoxOnly %clicking on label toggles checkbox
        DigIn %selection of a branch also checks all children
    end
    
    properties (Dependent=true, SetAccess=immutable, GetAccess=public)
        CheckedNodes %in DigIn, returns highest level that's fully checked
    end
    
    properties (SetAccess=protected, GetAccess=protected)
        jCBoxSelModel %Java checkbox selection model (internal)
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % A constructor method is a special function that creates an instance
    % of the class. Typically, constructor methods accept input arguments
    % to assign the data stored in properties and always return an
    % initialized object.
    methods
        function tObj = CheckboxTree(varargin)
            % CheckboxTree - Constructor for CheckboxTree
            % -------------------------------------------------------------------------
            % Abstract: Constructs a new CheckboxTree object.  No special
            % action is taken.
            %
            % Syntax:
            %           tObj = uiextras.jTree.CheckboxTree('p1',v1,...)
            %
            % Inputs:
            %           Property-value pairs
            %
            % Outputs:
            %           tObj - uiextras.jTree.CheckboxTree object
            %
            % Examples:
            %           hFig = figure;
            %           tObj = CheckboxTree('Parent',hFig)
            %
            
            % Call superclass constructor
            tObj = tObj@uiextras.jTree.Tree(varargin{:});
            
        end
        
    end %methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Public Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods are functions that implement the operations performed on
    % objects of a class. They may be stored within the classdef file or as
    % separate files in a @classname folder.
    methods
        
        function s = getJavaObjects(tObj)
            s = getJavaObjects@uiextras.jTree.Tree(tObj);
            s.jCBoxSelModel = tObj.jCBoxSelModel;
        end
        
    end %public methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Protected Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = protected)
        
        function createTree(tObj)
            % Override the createTree method to make a checkbox tree
            
            % Create the root node
            tObj.Root = uiextras.jTree.CheckboxTreeNode('Name','Root','Tree',tObj);
            
            % Create the tree
            if isempty(tObj.Root)
                tObj.jTree = javaObjectEDT('UIExtrasTree.CheckBoxTree');
            else
                tObj.jTree = javaObjectEDT('UIExtrasTree.CheckBoxTree',tObj.Root.jNode);
            end
            
            % Store the model
            tObj.jModel = tObj.jTree.getModel();
            javaObjectEDT(tObj.jModel); % Put it on the EDT
            
            % Store the selection model
            tObj.jSelModel = tObj.jTree.getSelectionModel();
            javaObjectEDT(tObj.jSelModel); % Put it on the EDT
            
            % Store the checkbox selection model
            tObj.jCBoxSelModel = tObj.jTree.getCheckBoxTreeSelectionModel();
            %tObj.jCBoxSelModel.setSingleEventMode(1);
            javaObjectEDT(tObj.jCBoxSelModel);
            
        end
        
        function createTreeCustomizations(tObj)
            % customize the tree for checkboxes
            
            % Call the superclass method
            createTreeCustomizations@uiextras.jTree.Tree(tObj)
            
            % Use the custom renderer
            setCellRenderer(tObj.jTree, UIExtrasTree.TreeCellRenderer);
            
            % Set the callbacks
            CbProps = handle(tObj.jCBoxSelModel,'CallbackProperties'); 
            set(CbProps,'ValueChangedCallback',@(src,e)onCheckboxClicked(tObj,e));
            
        end
        
        function onCheckboxClicked(tObj,e)
            
            if callbacksEnabled(tObj)
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Prepare event data for user callback
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % In non DigIn mode, provide the node that was changed. In
                % DigIn mode, the java event is difficult to use because we
                % get multiple events in some cases. (Single event mode did
                % not work correctly.)  The events may come in the wrong
                % order, giving wrong information. So instead, we just
                % provide the selection paths.
                if tObj.DigIn
                    
                    % Filter out clicks that trigger two events by checking
                    % for changes in the selection path. Note equals is
                    % defined as long as jOldSelPath is nonempty.
                    jNewSelPath = e.getNewLeadSelectionPath();
                    jOldSelPath = e.getOldLeadSelectionPath();
                    if ~isempty(jOldSelPath) && equals(jOldSelPath,jNewSelPath)
                        return
                    end
                    
                    % Prepare the event data
                    e1 = struct('SelectionPaths',tObj.CheckedNodes);
                    
                else %not DigIn mode
                    
                    % Figure out what paths were added or removed by eventdata
                    jChangedPath = e.getPath;
                    jPath = jChangedPath.getLastPathComponent();
                    ChangedPath = get(jPath,'TreeNode');
                    
                    % Prepare the event data
                    e1 = struct(...
                        'Nodes',ChangedPath,...
                        'SelectionPaths',tObj.CheckedNodes);
                    
                end %if tObj.DigIn
                
                % Is there a custom CheckboxClickedCallback?
                if ~isempty(tObj.CheckboxClickedCallback)
                    
                    % Call the custom callback
                    hgfeval(tObj.CheckboxClickedCallback,tObj,e1);
                    
                end %if ~isempty(tObj.CheckboxClickedCallback)
                
            end %if callbacksEnabled(tObj)
            
        end
        
    end %protected methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Special Access Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access={?uiextras.jTree.Tree, ?uiextras.jTree.TreeNode})
        
        function tf = isNodeChecked(tObj,nObj)
            jTreePath = nObj.jNode.getTreePath;
            if nObj.Tree == tObj
                tf = tObj.jCBoxSelModel.isPathSelected(jTreePath,tObj.DigIn);
            else
                tf = NaN;
            end
        end
        
        function tf = isNodePartiallyChecked(tObj,nObj)
            jTreePath = nObj.jNode.getTreePath;
            if nObj.Tree == tObj
                tf = tObj.jCBoxSelModel.isPartiallySelected(jTreePath);
            else
                tf = NaN;
            end
        end
        
        function setChecked(tObj,nObj,value)
            validateattributes(nObj,{'uiextras.jTree.TreeNode'},{'vector'});
            validateattributes(value,{'numeric','logical'},{'vector'});
            if isequal(size(value),size(nObj))
                value = logical(value);
            elseif numel(value)==1
                value = repmat(logical(value),size(nObj));
            else
                error('CheckboxTree:setChecked:inputs',...
                    'Size of value must match size of input nodes to be set.');
            end
            RemNodes = nObj(~value);
            AddNodes = nObj(value);
            if ~isempty(RemNodes)
                for idx = numel(RemNodes):-1:1 %backwards to preallocate
                    RemPaths(idx) = RemNodes(idx).jNode.getTreePath();
                end
                tObj.jCBoxSelModel.removeSelectionPaths(RemPaths);
            end
            if ~isempty(AddNodes)
                for idx = numel(AddNodes):-1:1 %backwards to preallocate
                    AddPaths(idx) = AddNodes(idx).jNode.getTreePath();
                end
                tObj.jCBoxSelModel.addSelectionPaths(AddPaths);
            end
        end
        
    end %special access methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get and Set Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get and set methods customize the behavior that occurs when code gets
    % or sets a property value.
    methods
        
        % ClickInCheckBoxOnly
        function value = get.ClickInCheckBoxOnly(nObj)
            value = get(nObj.jTree,'ClickInCheckBoxOnly');
        end
        function set.ClickInCheckBoxOnly(nObj,value)
            validateattributes(value,{'numeric','logical'},{'scalar'});
            nObj.jTree.setClickInCheckBoxOnly(logical(value));
        end
        
        % DigIn
        function value = get.DigIn(nObj)
            value = get(nObj.jTree,'DigIn');
        end
        function set.DigIn(nObj,value)
            validateattributes(value,{'numeric','logical'},{'scalar'});
            nObj.jTree.setDigIn(logical(value));
        end
        
        % CheckedNodes
        function value = get.CheckedNodes(nObj)
            p = nObj.jCBoxSelModel.getSelectionPaths;
            value = uiextras.jTree.TreeNode.empty(0,1);
            for idx = 1:numel(p)
                nObj = get(p(idx).getLastPathComponent(),'TreeNode');
                value(end+1) = nObj; %#ok<AGROW>
            end
        end
        
    end %get/set methods
    
    
end %classdef
