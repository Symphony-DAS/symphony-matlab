classdef ClassRepository < handle

    properties (Access = private)
        subtype
        searchPaths
        objectCache
        classNames
    end

    methods
        
        function obj = ClassRepository(subtype, searchPaths)
            obj.subtype = subtype;
            obj.setSearchPaths(searchPaths);
            obj.objectCache = containers.Map();
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
            obj.classNames = discover(obj.subtype, obj.searchPaths);
        end
        
        function i = getId(obj, object)
            className = class(object);
            if ~any(strcmp(className, obj.classNames))
                error('Object does not exist is repository');
            end
            i = className;
        end
        
        function i = getAllIds(obj)
            i = obj.classNames;
        end

        function o = get(obj, id)
            if ~any(strcmp(id, obj.classNames))
                error(['''' id ''' does not exist is repository']);
            end
            if obj.objectCache.isKey(id)
                o = obj.objectCache(id);
                return;
            end
            className = id;
            constructor = str2func(className);
            o = constructor();
            obj.objectCache(id) = o;
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