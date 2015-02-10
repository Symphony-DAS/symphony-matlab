function setSelectedValue(control, value)
    string = get(control, 'String');
    index = find(strcmp(string, value));
    set(control, 'Value', index);
end

