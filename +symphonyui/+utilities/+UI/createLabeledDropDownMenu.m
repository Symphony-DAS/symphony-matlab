function [c, layout] = createLabeledDropDownMenu(parent, label, sizes)
    import symphonyui.utilities.ui.*;
    layout = uiextras.HBox( ...
        'Parent', parent, ...
        'Spacing', 7);
    createLabel(layout, label);
    c = createDropDownMenu(layout, {' '});
    set(layout, 'Sizes', sizes);
end