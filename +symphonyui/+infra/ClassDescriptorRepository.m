classdef ClassDescriptorRepository < handle

    properties (Access = private)
        subtype
        searchPaths
        objects
    end

    methods
        
        function obj = ClassDescriptorRepository(subtype)
            obj.subtype = subtype;
        end

        function o = getAll(obj)
            o = obj.objects.values;
        end

        function o = getAllIds(obj)
            o = obj.objects.keys;
        end

        function o = get(obj, id)
            o = obj.objects(id);
        end

        function setSearchPaths(obj, paths)
            for i = 1:numel(paths)
                [~, parent] = symphonyui.util.packageName(paths{i});
                if exist(parent, 'dir')
                    addpath(parent);
                end
            end
            obj.searchPaths = paths;
        end

        function loadAll(obj)
            obj.objects = containers.Map();

            classNames = discover(obj.subtype, obj.searchPaths);
            for i = 1:numel(classNames)
                try %#ok<TRYNC>
                    obj.load(classNames{i});
                end
            end
        end

        function load(obj, className)
            clazz = meta.class.fromName(className);
            descriptor.id = clazz.Name;
            descriptor.class = clazz.Name;
            obj.objects(descriptor.id) = descriptor;
        end

    end

end

function names = discover(type, paths)
    names = {};

    for i = 1:numel(paths)
        package = symphonyui.util.packageName(paths{i});
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
