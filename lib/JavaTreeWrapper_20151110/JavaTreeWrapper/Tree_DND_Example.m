%% Create the figure and display the tree
% Copyright 2012-2015 The MathWorks, Inc.

function Tree_DND_Example

% cc
import uiextras.jTree.*
f = figure;
t = Tree('Parent',f);
assignin('base','t',t);
%% Create tree nodes
Node1 = TreeNode('Name','Node_1','Parent',t.Root);
Node2 = TreeNode('Name','Node_2','Parent',t.Root);
Node3 = TreeNode('Name','Node_3','Parent',t.Root);
Node4 = TreeNode('Name','Node_4','Parent',t.Root);
Node5 = TreeNode('Name','Node_5','Parent',t.Root);
Node6 = TreeNode('Name','Node_6','Parent',t.Root);

%% Set an icon
Icon1 = fullfile(matlabroot,'toolbox','matlab','icons','pagesicon.gif');
setIcon(Node1,Icon1);
setIcon(Node2,Icon1);
setIcon(Node3,Icon1);
setIcon(Node4,Icon1);
setIcon(Node5,Icon1);
setIcon(Node6,Icon1);
%% Enable the tree
t.Enable = true;

%% Drag and drop
t.DndEnabled = true;

%% Editability
t.Editable = true;
%t.NodeEditedCallback = @(s,e)testcallback(s,e);
t.NodeDraggedCallback = @(s,e)DragDrop_NODE_Callback(s,e);
t.NodeDroppedCallback = @(s,e)DragDrop_NODE_Callback(s,e);


function DropOk = DragDrop_NODE_Callback(s,e)

% Is this the drag or drop part?
DoDrop = ~(nargout); % The drag callback expects an output, drop does not

% Get the source and destination
Src = e.Source;
Dst = e.Target;

% If drop is allowed
DropOk = true;
if DoDrop && strcmpi(e.DropAction,'move')
    % De-parent
    Src.Parent = [];
    % Then get index of destination
    Children = [Dst.Parent.Children];
    MatchDst = find(Children == Dst);
    
    % Re-order children and re-parent
    Children = [Children(1:(MatchDst-1)) Src Children(MatchDst:end)];
    for index = 1:numel(Children)
        Children(index).Parent = Dst.Parent;
    end
end
    
    
