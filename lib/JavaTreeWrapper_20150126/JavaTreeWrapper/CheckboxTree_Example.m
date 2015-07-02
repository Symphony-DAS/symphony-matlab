%% Create the figure and display the tree
% Copyright 2012-2014 The MathWorks, Inc.

import uiextras.jTree.*
f = figure;
t = CheckboxTree('Parent',f);

%% Create tree nodes
Node1 = CheckboxTreeNode('Name','Node_1','Parent',t.Root);
Node1_1 = CheckboxTreeNode('Name','Node_1_1','Parent',Node1,'TooltipString','Node1_1');
Node1_2 = CheckboxTreeNode('Name','Node_1_2','Parent',Node1,'TooltipString','Node1_2');
Node2 = CheckboxTreeNode('Name','Node_2','Parent',t.Root);

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

%% Selection by click in check box only, or on labels too?

% Turn this off
t.ClickInCheckBoxOnly = 0;

%% Node editing
 
% Editable nodes
t.Editable = true;
