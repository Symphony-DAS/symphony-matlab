classdef Discoverer < handle
    
    properties
        classNames
    end
    
    properties (SetAccess = private)
        type
        paths
    end
    
    methods
        
        function obj = Discoverer(type)
            obj.type = type;
        end
        
        function setPaths(obj, paths)
            for i = 1:length(paths)
                [~, parent] = symphonyui.util.packageName(paths{i});
                addpath(parent);
            end
            obj.paths = paths;
        end
        
        function discover(obj)
            obj.classNames = {};

            for i = 1:length(obj.paths)
                path = obj.paths{i};

                package = symphonyui.util.packageName(path);
                if ~isempty(package)
                    package = [package '.']; %#ok<AGROW>
                end

                listing = dir(fullfile(path, '*.m'));
                for k = 1:length(listing)
                    className = [package listing(k).name(1:end-2)];
                    try
                        super = superclasses(className);
                    catch
                        continue;
                    end
                    
                    if any(strcmp(super, obj.type))
                        obj.classNames{end + 1} = className;
                    end
                end
            end
        end
        
    end
    
end

