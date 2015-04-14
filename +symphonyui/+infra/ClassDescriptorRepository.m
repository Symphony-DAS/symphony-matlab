classdef ClassDescriptorRepository < handle

    properties (Access = private)
        subtype
        searchPaths
        idToDescriptor
    end

    methods
        
        function obj = ClassDescriptorRepository(subtype)
            obj.subtype = subtype;
        end

        function o = getAll(obj)
            o = obj.idToDescriptor.values;
        end

        function o = getAllIds(obj)
            o = obj.idToDescriptor.keys;
        end

        function o = get(obj, id)
            o = obj.idToDescriptor(id);
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
            obj.idToDescriptor = containers.Map();

            classNames = discover(obj.subtype, obj.searchPaths);
            for i = 1:numel(classNames)
                try %#ok<TRYNC>
                    obj.load(classNames{i});
                end
            end
        end
        
        function load(obj, className)
            clazz = meta.class.fromName(className);
            split = strsplit(clazz.Name, '.');
            descriptor.id = humanize(split{end});
            descriptor.class = clazz.Name;
            obj.idToDescriptor(descriptor.id) = descriptor;
        end

    end

end

function names = discover(type, paths)
    names = {};

    for i = 1:numel(paths)
        package = packageName(paths{i});
        if ~isempty(package)
            package = [package '.']; %#ok<AGROW>
        end

        listing = dir(fullfile(paths{i}, '*.m'));
        for k = 1:numel(listing)
            className = [package listing(k).name(1:end-2)];
            try
                super = superclasses(className);
            catch
                continue;
            end

            if ~any(strcmp(super, type))
                continue;
            end
            
            names{end + 1} = className;
        end
    end
end

function n = humanize(n)
    n = regexprep(n, '([A-Z][a-z]+)', ' $1');
    n = regexprep(n, '([A-Z][A-Z]+)', ' $1');
    n = regexprep(n, '([^A-Za-z ]+)', ' $1');
    n = strtrim(n);
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