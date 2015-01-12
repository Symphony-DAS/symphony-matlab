function setSelectedPopupValue(popup, value)
    string = get(popup, 'String');
    index = find(strcmp(string, value));
    set(popup, 'Value', index);
end

