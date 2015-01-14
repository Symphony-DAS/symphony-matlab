function v = getSelectedUIValue(control)
    string = get(control, 'String');
    if ~isempty(string)
        value = get(control, 'Value');
        v = string{value};
    else
        v = [];
    end
end

