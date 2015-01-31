function map = displayNameMap(list)
    map = Map2();
    for i = 1:numel(list);
        className = list{i};
        displayName = symphonyui.utilities.classProperty(className, 'displayName');
        if isKey(map, displayName)
            value = map(displayName);
            map.remove(displayName);
            map([displayName ' (' value ')']) = value;
            
            displayName = [displayName ' (' className ')'];
        end
        map(displayName) = className;
    end
end

