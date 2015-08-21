classdef ClassRepository < handle

    properties (Access = private)
        log
        subtype
        searchPaths
        classes
    end

    methods
        
        function obj = ClassRepository(subtype, searchPaths)
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.subtype = subtype;
            obj.setSearchPaths(searchPaths);
            obj.loadAll();
        end
        
        function setSearchPaths(obj, paths)
            for i = 1:numel(paths)
                [~, parent] = packageName(paths{i});
                if exist(parent, 'dir')
                    addpath(parent);
                end
            end
            obj.searchPaths = paths;
        end

        function loadAll(obj)
            loaded = {};

            for i = 1:numel(obj.searchPaths)
                package = packageName(obj.searchPaths{i});
                if ~isempty(package)
                    package = [package '.']; %#ok<AGROW>
                end

                listing = dir(fullfile(obj.searchPaths{i}, '*.m'));
                for k = 1:numel(listing)
                    className = [package listing(k).name(1:end-2)];
                    try
                        super = superclasses(className);
                    catch x
                        obj.log.debug(x.message, x);
                        continue;
                    end

                    if ~any(strcmp(super, obj.subtype))
                        continue;
                    end

                    try
                        m = meta.class.fromName(className);
                        if ~m.Abstract
                            loaded{end + 1} = className; %#ok<AGROW>
                        end
                    catch x
                        obj.log.debug(x.message, x);
                        continue;
                    end
                end
            end
            
            obj.classes = loaded;
        end
        
        function o = getAll(obj)
            o = obj.classes;
        end

    end

end

function [name, parentPath] = packageName(path)
    if isempty(path)
        name = [];
        parentPath = [];
        return;
    end
    [parentPath, name] = strtok(path, '+');
    name = regexp(name, '\+(\w)+', 'tokens');
    name = strcat([name{:}], [repmat({'.'},1,numel(name)-1) {''}]);
    name = [name{:}];
end