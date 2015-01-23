function classNames = search(paths, superclass)
    import SymphonyUI.Utilities.*;
    
    if ~iscell(paths)
        paths = {paths};
    end
    
    classNames = {};
    
    for i = 1:length(paths)
        path = paths{i};
        
        package = packageName(path);
        if ~isempty(package)
            package = [package '.'];
        end

        listing = dir(fullfile(path, '*.m'));
        for k = 1:length(listing)
            className = [package listing(k).name(1:end-2)];
            if any(strcmp(superclasses(className), superclass))
                classNames{end + 1} = className;
            end
        end
    end
end

