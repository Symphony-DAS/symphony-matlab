% A silly hack to get vertically aligned drop-down menus.

function c = createDropDownMenu(parent, string)
    vbox = uiextras.VBox('Parent', parent);
    uiextras.Empty('Parent', vbox);
    c = uicontrol( ...
        'Parent', vbox, ...
        'Style', 'popupmenu', ...
        'String', string, ...
        'HorizontalAlignment', 'left');
    if ismac
        set(vbox, 'Sizes', [1 -1]);
    else
        set(vbox, 'Sizes', [1 -1]);
    end
end