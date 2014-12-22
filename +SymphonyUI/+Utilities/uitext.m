% A silly hack to get vertically aligned labels.

function c = uitext(parent, string)
    vbox = uiextras.VBox('Parent', parent);
    uiextras.Empty('Parent', vbox);
    c = uicontrol( ...
        'Parent', vbox, ...
        'Style', 'text', ...
        'String', string, ...
        'HorizontalAlignment', 'left');
    if ismac
        set(vbox, 'Sizes', [3 -1]);
    else
        set(vbox, 'Sizes', [5 -1]);
    end
end