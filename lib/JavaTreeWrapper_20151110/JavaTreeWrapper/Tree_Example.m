%% Create the figure and display the tree
% Copyright 2012-2014 The MathWorks, Inc.

import uiextras.jTree.*
f = figure;
t = Tree('Parent',f);

%% Create and remove tree nodes
Node1 = TreeNode('Name','Node_1_original','Parent',t.Root);
delete(Node1);
Node1 = TreeNode('Name','Node_1','Parent',t.Root);
Node1_1 = TreeNode('Name','Node_1_1','Parent',Node1,'TooltipString','Node1_1');
Node1.expand();
Node1_2 = TreeNode('Name','Node_1_2','Parent',Node1,'TooltipString','Node1_2');
Node2 = TreeNode('Name','Node_2','Parent',t.Root);
delete(Node1_2);
Node1_2 = TreeNode('Name','Node_1_2','Parent',Node1,'TooltipString','Node1_2');

%% Rename a node

Node1_1.Name = 'Node_1_1 (renamed)';

%% Set an icon
Icon1 = fullfile(matlabroot,'toolbox','matlab','icons','pagesicon.gif');
Icon2 = fullfile(matlabroot,'toolbox','matlab','icons','pageicon.gif');
setIcon(Node1,Icon1);
setIcon(Node1_1,Icon2);
setIcon(Node1_2,Icon2);
setIcon(Node2,Icon1);

%% Move nodes around
Node1_2.Parent = t;

%% Disable the tree
t.Enable = false;

%% Enable the tree
t.Enable = true;

%% Add a context menu

% For the whole tree
u1 = uicontextmenu('Parent',f);
m1 = uimenu(u1,'Label','Refresh');
set(t,'UIContextMenu',u1)

% For Node_1 only
u2 = uicontextmenu('Parent',f);
m2 = uimenu(u2,'Label','Node1');
set(Node1,'UIContextMenu',u2)

%% Select nodes
t.SelectionType = 'discontiguous';
t.SelectedNodes = [Node1_2 Node1];

%% Drag and drop
t.DndEnabled = true;

%% Editability
t.Editable = true;
t.NodeEditedCallback = @(s,e)testcallback(s,e);

%% Hide the root
t.RootVisible = false;

