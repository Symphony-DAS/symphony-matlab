function [c, layout] = createLabeledDropDownMenu(parent, label, labelSize)
    import symphonyui.ui.util.*;
    layout = uiextras.HBox( ...
        'Parent', parent, ...
        'Spacing', 7);
    createLabel(layout, label);
    c = createDropDownMenu(layout, {' '});
    set(layout, 'Sizes', [labelSize -1]);
end
