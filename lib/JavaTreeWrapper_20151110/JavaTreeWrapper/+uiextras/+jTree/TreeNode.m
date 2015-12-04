classdef TreeNode < hgsetget & matlab.mixin.Heterogeneous
    % TreeNode - Defines a node for a tree control
    %   The TreeNode object defines a tree node to be placed on a
    %   uiextras.jTree.Tree control.
    %
    % Syntax:
    %   nObj = uiextras.jTree.TreeNode
    %   nObj = uiextras.jTree.TreeNode('Property','Value',...)
    %
    % TreeNode Properties:
    %
    %   Name - Name to display on the tree node
    %
    %   Value - User value to store in the tree node
    %
    %   TooltipString - Tooltip text on mouse hover
    %
    %   UserData - User data to store in the tree node
    %
    %   Parent - Parent tree node
    %
    %   UIContextMenu - context menu to show when clicking on this node
    %
    %   Children - Child tree nodes (read-only)
    %
    %   Tree - Tree on which this node is attached (read-only)
    %
    % TreeNode Methods:
    %
    %   copy - makes a copy of the node for use in another tree
    %
    %   collapse - collapse the node
    %
    %   expand - expand the node
    %
    %   isAncestor - checks if another node is an ancestor of this one
    %
    %   isDescendant - checks if another node is a descendant of this one
    %
    %   setIcon - set the icon displayed on this tree node
    %
    % See also: uiextras.jTree.Tree, uiextras.jTree.CheckboxTree,
    %           uiextras.jTree.CheckboxTreeNode
    %
    
    %   Copyright 2012-2015 The MathWorks, Inc.
    %
    % Auth/Revision:
    %   MathWorks Consulting
    %   $Author: rjackey $
    %   $Revision: 1245 $  $Date: 2015-11-06 09:19:24 -0500 (Fri, 06 Nov 2015) $
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
        Name %Name to display on the tree node
        Value %User value to store in the tree node
        TooltipString %Tooltip text on mouse hover
        UserData %User data to store in the tree node
    end
    
    properties
        Parent = uiextras.jTree.TreeNode.empty(0,1) %Parent tree node
        UIContextMenu %context menu to show when clicking on this node
    end
    
    properties (SetAccess=protected, GetAccess=public)
        Children = uiextras.jTree.TreeNode.empty(0,1) %Child tree nodes
        Tree = uiextras.jTree.Tree.empty(0,1) %Tree on which this node is attached
    end
    
    % The node needs to be accessible to the nodes also
    properties (SetAccess={?uiextras.jTree.Tree, ?uiextras.jTree.TreeNode},...
            GetAccess={?uiextras.jTree.Tree, ?uiextras.jTree.TreeNode})
        jNode %Java object for tree node
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % A constructor method is a special function that creates an instance
    % of the class. Typically, constructor methods accept input arguments
    % to assign the data stored in properties and always return an
    % initialized object.
    methods
        function nObj = TreeNode(varargin)
            % TreeNode - Constructor for TreeNode
            % -------------------------------------------------------------------------
            % Abstract: Constructs a new TreeNode object.  No special
            % action is taken.
            %
            % Syntax:
            %   nObj = uiextras.jTree.TreeNode
            %   nObj = uiextras.jTree.TreeNode('Property','Value',...)
            %
            % Inputs:
            %           Property-value pairs
            %
            % Outputs:
            %           nObj - TreeNode object
            %
            % Examples:
            %           nObj = TreeNode()
            %
            
            % Add the custom java paths
            uiextras.jTree.loadJavaCustomizations();
            
            % Create a tree node for this element
            nObj.jNode = handle(javaObjectEDT('UIExtrasTree.TreeNode'));
            
            % Add properties to the java object for MATLAB data
            schema.prop(nObj.jNode,'Value','MATLAB array');
            schema.prop(nObj.jNode,'TreeNode','MATLAB array');
            schema.prop(nObj.jNode,'UserData','MATLAB array');
            
            % Add a reference to this object
            nObj.jNode.TreeNode = nObj;
            
            % Set user-supplied property values
            if ~isempty(varargin)
                set(nObj,varargin{:});
            end
            
        end
    end %methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Destructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function delete(nObj)
            delete(nObj.Children(isvalid(nObj.Children)))
            nObj.Children(:) = [];
            nObj.Parent(:) = [];
            delete(nObj.jNode);
        end
    end %methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Public Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods are functions that implement the operations performed on
    % objects of a class. They may be stored within the classdef file or as
    % separate files in a @classname folder.
    methods
        
        function nObjCopy = copy(nObj,NewParent)
            % copy - Copy a TreeNode object
            % -------------------------------------------------------------------------
            % Abstract: Copy a TreeNode object, including any children
            %
            % Syntax:
            %           nObj.copy()
            %           nObj.copy(NewParent)
            %
            % Inputs:
            %           nObj - TreeNode object to copy
            %           NewParent - new parent TreeNode object
            %
            % Outputs:
            %           nObjCopy - copy of TreeNode object
            %
            for idx = 1:numel(nObj)
                
                % Allow subclasses to instantiate copies of the same type
                fNodeConstructor = str2func(class(nObj(idx)));
                
                % Create a new node, and copy properties
                nObjCopy(idx) = fNodeConstructor(...
                    'Name',nObj(idx).Name,...
                    'Value',nObj(idx).Value,...
                    'TooltipString',nObj(idx).TooltipString,...
                    'UserData',nObj(idx).UserData,...
                    'UIContextMenu',nObj(idx).UIContextMenu); %#ok<AGROW>
                
                % Copy the icon's java object
                jIcon = getIcon(nObj(idx).jNode);
                setIcon(nObjCopy(idx).jNode,jIcon);
                
                % Set the parent, if specified
                if nargin>1
                    set(nObjCopy(idx),'Parent',NewParent);
                end
                
                % Recursively copy children and assign new parent
                % Need to loop in case children are of heterogeneous type
                ChildNodes = nObj(idx).Children;
                for cIdx = 1:numel(ChildNodes)
                    copy(ChildNodes(cIdx), nObjCopy(idx));
                end
            end
        end
        
        function collapse(nObj)
            % collapse - Collapse a TreeNode within a tree
            % -------------------------------------------------------------------------
            % Abstract: Collapses the TreeNode
            %
            % Syntax:
            %           nObj.collapse()
            %
            % Inputs:
            %           nObj - TreeNode object
            %
            % Outputs:
            %           none
            %
            for idx = 1:numel(nObj)
                if ~isempty(nObj(idx).Tree)
                    collapseNode(nObj(idx).Tree, nObj(idx));
                end
            end
        end %function collapse()
        
        function expand(nObj)
            % expand - Expands a TreeNode within a tree
            % -------------------------------------------------------------------------
            % Abstract: Expands the TreeNode
            %
            % Syntax:
            %           nObj.expand()
            %
            % Inputs:
            %           nObj - TreeNode object
            %
            % Outputs:
            %           none
            %
            for idx = 1:numel(nObj)
                if ~isempty(nObj(idx).Tree)
                    expandNode(nObj(idx).Tree, nObj(idx));
                end
            end
        end %function expand()
        
        function tf = isAncestor(nObj1,nObj2)
            % isAncestor - checks if another node is an ancestor
            % -------------------------------------------------------------------------
            % Abstract: checks if node2 is an ancestor of node 1
            %
            % Syntax:
            %           tf = nObj1.isAncestor(nObj2)
            %
            % Inputs:
            %           nObj1 - TreeNode object
            %           nObj2 - TreeNode object
            %
            % Outputs:
            %           tf - logical result
            %
            validateattributes(nObj1,{'uiextras.jTree.TreeNode'},{'vector'})
            validateattributes(nObj2,{'uiextras.jTree.TreeNode'},{'vector'})
            
            tf = false(size(nObj1));
            for idx = 1:numel(nObj1)
                while ~tf(idx) && ~isempty(nObj1(idx).Parent)
                    tf(idx) = any(nObj1(idx).Parent == nObj2);
                    nObj1(idx) = nObj1(idx).Parent;
                end
            end
            
        end %function isAncestor()
        
        function tf = isDescendant(nObj1,nObj2)
            % isDescendant - checks if another node is a descendant
            % -------------------------------------------------------------------------
            % Abstract: checks if another node is a descendant of this one
            %
            % Syntax:
            %           tf = nObj1.isDescendant(nObj2)
            %
            % Inputs:
            %           nObj1 - TreeNode object
            %           nObj2 - TreeNode object
            %
            % Outputs:
            %           tf - logical result
            %
            
            tf = isAncestor(nObj2,nObj1);
            
        end %function isDescendant()
        
        function setIcon(nObj,icon)
            % setIcon - Set icon of TreeNode
            % -------------------------------------------------------------------------
            % Abstract: Changes the icon displayed on a TreeNode
            %
            % Syntax:
            %           nObj.setIcon(IconFilePath)
            %
            % Inputs:
            %           nObj - TreeNode object
            %           icon - path to the icon file (16x16 px)
            %
            % Outputs:
            %           none
            %
            % Examples:
            %   t = uiextras.jTree.Tree;
            %   n = uiextras.jTree.TreeNode('Name','Node1','Parent',t);
            %   setIcon(n,which('matlabicon.gif'));
            
            validateattributes(icon,{'char'},{})
            
            % Create a java icon
            IconData = javaObjectEDT('javax.swing.ImageIcon',icon);
            
            % Update the icon in the node
            setIcon(nObj.jNode, IconData);
            
            % Notify the model about the update
            nodeChanged(nObj.Tree, nObj)
            
        end %function setIcon()
        
        function s = getJavaObjects(nObj)
            % getJavaObjects - Returns underlying java objects
            % -------------------------------------------------------------------------
            % Abstract: (For debugging use only) Returns the underlying
            % Java objects.
            %
            % Syntax:
            %           s = getJavaObjects(nObj)
            %
            % Inputs:
            %           nObj - TreeNode object
            %
            % Outputs:
            %           s - struct of Java objects
            %
            
            s = struct('jNode',nObj.jNode);
        end
        
    end %public methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Protected Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = protected)
        
        function newParent = updateParent(nObj,newParent)
            
            % Is the new parent empty?
            if isempty(newParent)
                
                % Always make the parent an empty TreeNode, in case empty
                % [] was passed in
                newParent = uiextras.jTree.TreeNode.empty(0,1);
                
                % Is there an old parent to clean up?
                if ~isempty(nObj.Parent)
                    ChildIdx = find(nObj.Parent.Children == nObj,1);
                    nObj.Parent.Children(ChildIdx) = [];
                    nObj.Tree.removeNode(nObj, nObj.Parent);
                end
                
                % Update the reference to the tree in the hierarchy
                EmptyTree = uiextras.jTree.Tree.empty(0,1);
                updateTreeReference(nObj, EmptyTree)
                
            else % A new parent was provided
                
                % If new parent is a Tree, parent is the Root
                if isa(newParent,'uiextras.jTree.Tree')
                    newParent = newParent.Root;
                end
                
                % Is there an old parent to clean up?
                if ~isempty(nObj.Parent)
                    ChildIdx = find(nObj.Parent.Children == nObj,1);
                    nObj.Parent.Children(ChildIdx) = [];
                    nObj.Tree.removeNode(nObj, nObj.Parent);
                end
                
                % Update the reference to the tree in the hierarchy
                updateTreeReference(nObj,newParent.Tree)
                
                % Update the list of children in the parent
                ChildIdx = numel(newParent.Children) + 1;
                newParent.Children(ChildIdx) = nObj;
                
                % Add this node to the parent node
                nObj.Tree.insertNode(nObj, newParent, ChildIdx);
                
            end %if isempty(newParent)
            
            % This internal function updates the tree reference in the
            % hierarchy
            function updateTreeReference(nObj,Tree)
                for idx=1:numel(nObj)
                    nObj(idx).Tree = Tree;
                    if ~isempty(nObj(idx).Children)
                        updateTreeReference(nObj(idx).Children, Tree);
                    end
                end
            end
            
        end %function updateParent()
        
    end %protected methods
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get and Set Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get and set methods customize the behavior that occurs when code gets
    % or sets a property value.
    methods
        
        % Name
        function value = get.Name(nObj)
            value = nObj.jNode.getUserObject();
        end
        function set.Name(nObj,value)
            validateattributes(value,{'char'},{});
            nObj.jNode.setUserObject(value);
            nodeChanged(nObj.Tree,nObj);
        end
        
        % Value
        function value = get.Value(nObj)
            value = nObj.jNode.Value;
        end
        function set.Value(nObj,value)
            nObj.jNode.Value = value;
        end
        
        % TooltipString
        function value = get.TooltipString(nObj)
            value = char(nObj.jNode.getTooltipString());
        end
        function set.TooltipString(nObj,value)
            validateattributes(value,{'char'},{});
            nObj.jNode.setTooltipString(java.lang.String(value));
        end
        
        % UserData
        function value = get.UserData(nObj)
            value = nObj.jNode.UserData;
        end
        function set.UserData(nObj,value)
            nObj.jNode.UserData = value;
        end
        
        % Parent
        function set.Parent(nObj,newParent)
            % Update the parent/child relationship
            newParent = updateParent(nObj,newParent);
            % Set the parent value
            nObj.Parent = newParent;
        end
        
        % UIContextMenu
        function set.UIContextMenu(tObj,value)
            tObj.UIContextMenu = value;
        end
        
    end %get/set methods
    
end %classdef
