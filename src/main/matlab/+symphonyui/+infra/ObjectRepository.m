classdef ObjectRepository < handle

    properties (Access = private)
        subtype
        searchPaths
        objects
    end

    methods
        
        function obj = ObjectRepository(subtype, searchPaths)
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
            obj.objects = discover(obj.subtype, obj.searchPaths);
        end
        
        function o = getAll(obj)
            o = obj.objects;
        end

    end

end

function objects = discover(type, paths)
    objects = {};

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
            
            try
                constructor = str2func(className);
                objects{end + 1} = constructor(); %#ok<AGROW>
            catch
                continue;
            end
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