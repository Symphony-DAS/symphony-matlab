classdef CheckboxTreeNode < uiextras.jTree.TreeNode
    % CheckboxTreeNode - Defines a node for a checkbox tree control
    %   The CheckboxTreeNode object defines a checkbox tree node to be
    %   placed on a uiextras.jTree.CheckboxTree control.
    %
    % Syntax:
    %   nObj = uiextras.jTree.CheckboxTreeNode
    %   nObj = uiextras.jTree.CheckboxTreeNode('Property','Value',...)
    %
    %   The CheckboxTree contains all properties and methods of the
    %   <a href="matlab:doc uiextras.jTree.TreeNode">uiextras.jTree.TreeNode</a>, plus the following:
    %
    % CheckboxTreeNode Properties:
    %
    %   CheckboxEnabled - Indicates whether the checkbox on this node may
    %   be selected with the mouse
    %
    %   CheckboxVisible - Indicates whether the checkbox on this node is
    %   visible
    %
    %   Checked - Indicates whether the checkbox on this node is checked
    %
    %   PartiallyChecked - Indicates whether the checkbox on this node is
    %   partially checked, in the case where some child nodes are checked
    %   under DigIn mode(read-only)
    %
    % Notes:
    %   - The CheckboxTreeNode may be also used on a uiextras.jTree.Tree
    %   control, but the checkboxes will not be visible. This may be useful
    %   if you are mixing regular trees with checkbox trees, and want to
    %   use a uniform type of TreeNode or need to be able to drag and drop
    %   from one tree to another.
    %
    % See also: uiextras.jTree.Tree, uiextras.jTree.CheckboxTree,
    %           uiextras.jTree.TreeNode,
    %
    %
    
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
    properties (Dependent=true, SetAccess=public, GetAccess=public)
        CheckboxEnabled %Indicates whether checkbox may be selected with the mouse
        CheckboxVisible %Indicates whether checkbox is visible
        Checked %Indicates whether checkbox is checked
    end
    
    properties (Dependent=true, SetAccess=immutable, GetAccess=public)
        PartiallyChecked %Indicates whether checkbox is partially checked
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % A constructor method is a special function that creates an instance
    % of the class. Typically, constructor methods accept input arguments
    % to assign the data stored in properties and always return an
    % initialized object.
    methods
        function nObj = CheckboxTreeNode(varargin)
            % TreeNode - Constructor for TreeNode
            % -------------------------------------------------------------------------
            % Abstract: Constructs a new TreeNode object.  No special
            % action is taken.
            %
            % Syntax:
            %           nObj = TreeNode('property1',value1,...)
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
            
            % Call superclass constructor
            nObj = nObj@uiextras.jTree.TreeNode(varargin{:});
            
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
            % Abstract: Copy a TreeNode object
            %
            % Syntax:
            %           nObj.copy()
            %
            % Inputs:
            %           nObj - TreeNode object to copy
            %           NewParent - new parent TreeNode object
            %
            % Outputs:
            %           nObjCopy - copy of TreeNode object
            %
            
            % Call the superclass copy
            nObjCopy = copy@uiextras.jTree.TreeNode(nObj,NewParent);
            
            % Copy the CheckboxTreeNode properties
            for idx = 1:numel(nObj)
                nObjCopy(idx).CheckboxEnabled = nObj(idx).CheckboxEnabled;
                nObjCopy(idx).CheckboxVisible = nObj(idx).CheckboxVisible;
                nObjCopy(idx).Checked = nObj(idx).Checked;
            end
        end
        
    end %public methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get and Set Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get and set methods customize the behavior that occurs when code gets
    % or sets a property value.
    methods
        
        % CheckboxEnabled
        function value = get.CheckboxEnabled(nObj)
            value = nObj.jNode.CheckBoxEnabled;
        end
        function set.CheckboxEnabled(nObj,value)
            validateattributes(value,{'numeric','logical'},{'scalar'});
            nObj.jNode.CheckBoxEnabled = logical(value);
            nodeChanged(nObj.Tree, nObj)
        end
        
        % CheckboxVisible
        function value = get.CheckboxVisible(nObj)
            value = nObj.jNode.CheckBoxVisible;
        end
        function set.CheckboxVisible(nObj,value)
            validateattributes(value,{'numeric','logical'},{'scalar'});
            nObj.jNode.CheckBoxVisible = logical(value);
            nodeChanged(nObj.Tree, nObj)
        end
        
        % Checked
        function value = get.Checked(nObj)
            value = true(1,0);
            if ~isempty(nObj.Tree) && isa(nObj.Tree,'uiextras.jTree.CheckboxTree')
                value = isNodeChecked(nObj.Tree,nObj);
            end
        end
        function set.Checked(nObj,value)
            validateattributes(value,{'numeric','logical'},{'scalar'});
            setChecked(nObj.Tree,nObj,value);
        end
        
        % PartiallyChecked
        function value = get.PartiallyChecked(nObj)
            value = true(1,0);
            if ~isempty(nObj.Tree) && isa(nObj.Tree,'uiextras.jTree.CheckboxTree')
                value = isNodePartiallyChecked(nObj.Tree,nObj);
            end
        end
        
    end %get/set methods
    
end %classdef
