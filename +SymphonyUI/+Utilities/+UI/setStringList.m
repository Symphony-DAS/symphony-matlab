function setStringList(control, list)
    value = get(control, 'Value');
    if value < 1
        value = 1;
    end
    if value > length(list)
        value = length(list);
    end
    set(control, 'Value', value);
    set(control, 'String', list);
end

