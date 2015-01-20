function [c, layout] = createLabeledDropDownMenu(parent, label, sizes)
    layout = uiextras.HBox( ...
        'Parent', parent, ...
        'Spacing', 7);
    SymphonyUI.Utilities.UI.createLabel(layout, label);
    c = SymphonyUI.Utilities.UI.createDropDownMenu(layout, {' '});
    set(layout, 'Sizes', sizes);
end