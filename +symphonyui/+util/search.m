function [classNames, exceptions] = search(paths, superclass)
    import symphonyui.util.*;
    
    if ~iscell(paths)
        paths = {paths};
    end
    
    classNames = {};
    exceptions = {};
    
    for i = 1:length(paths)
        path = paths{i};
        
        package = packageName(path);
        if ~isempty(package)
            package = [package '.'];
        end

        listing = dir(fullfile(path, '*.m'));
        for k = 1:length(listing)
            className = [package listing(k).name(1:end-2)];
            try
                super = superclasses(className);
            catch x
                exceptions{end + 1} = x;
                continue;
            end
            
            if any(strcmp(super, superclass))
                classNames{end + 1} = className;
            end
        end
    end
end

