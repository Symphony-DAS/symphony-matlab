function testcallback(src,evt)
% Copyright 2015 The MathWorks, Inc.

disp('callback fired');
for idx = 1:numel(evt)
    if isfield(evt,'EditedNode')
        disp(evt.EditedNode(idx).Name);
    elseif isfield(evt,'Nodes')
        disp({evt.Nodes.Name});
    else
        disp(evt);
    end
end
