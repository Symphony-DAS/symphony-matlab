% A silly hack to get vertically aligned labels.

function l = uitext(parent, string)
    l = uiextras.VBox('Parent', parent);
    uiextras.Empty('Parent', l);
    obj.controls.nameText = uicontrol( ...
        'Parent', l, ...
        'Style', 'text', ...
        'String', string, ...
        'HorizontalAlignment', 'left');
    if ismac
        set(l, 'Sizes', [3 -1]);
    else
        set(l, 'Sizes', [5 -1]);
    end
end