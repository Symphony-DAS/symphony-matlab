function v = getSelectedUIValue(control)
    string = get(control, 'String');
    value = get(control, 'Value');
    v = string{value};
end

