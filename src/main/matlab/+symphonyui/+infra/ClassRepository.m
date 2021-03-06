classdef ClassRepository < handle

    properties (Access = private)
        log
        excludeExpressions
        searchPath
        classMap
    end

    methods

        function obj = ClassRepository(path, exclude)
            if nargin < 2
                exclude = '';
            end
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.excludeExpressions = strtrim(strsplit(exclude, ';'));
            obj.setSearchPath(path);
        end

        function setSearchPath(obj, path)
            dirs = strsplit(path, ';');
            for i = 1:numel(dirs)
                if exist(dirs{i}, 'dir')
                    [~, ~, p] = appbox.packageName(dirs{i});
                    addpath(p);
                end
            end
            obj.searchPath = path;
            obj.loadAll();
        end

        function cn = get(obj, superclass)
            if obj.classMap.isKey(superclass)
                cn = obj.classMap(superclass);
            else
                cn = {};
            end
        end

    end

    methods (Access = private)

        function loadAll(obj)
            obj.classMap = containers.Map();

            dirs = strsplit(obj.searchPath, ';');
            for i = 1:numel(dirs)
                obj.loadDirectory(dirs{i});
            end
        end

        function loadDirectory(obj, path)
            package = appbox.packageName(path);
            if ~isempty(package)
                package = [package '.'];
            end

            listing = dir(path);
            for i = 1:numel(listing)
                l = listing(i);
                [~, name, ext] = fileparts(l.name);
                if strcmpi(ext, '.m') && exist([package name], 'class')
                    if ~isempty(cell2mat(regexp([package name], obj.excludeExpressions, 'once')))
                        continue;
                    end
                    try
                        obj.loadClass([package name]);
                    catch x
                        obj.log.debug(x.message, x);
                        continue;
                    end
                elseif ~isempty(name) && name(1) == '+'
                    obj.loadDirectory(fullfile(path, l.name));
                end
            end
        end

        function loadClass(obj, name)
            m = meta.class.fromName(name);
            if ~m.Abstract
                supers = superclasses(name);
                for i = 1:numel(supers)
                    s = supers{i};
                    if obj.classMap.isKey(s)
                        classes = obj.classMap(s);
                        if ~any(strcmp(name, classes))
                            classes = [classes name]; %#ok<AGROW>
                        end
                    else
                        classes = {name};
                    end
                    obj.classMap(s) = classes;
                end
            end
        end

    end

end
