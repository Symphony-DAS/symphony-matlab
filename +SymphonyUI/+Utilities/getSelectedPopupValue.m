function v = getSelectedPopupValue(popup)
    string = get(popup, 'String');
    value = get(popup, 'Value');
    v = string{value};
end

