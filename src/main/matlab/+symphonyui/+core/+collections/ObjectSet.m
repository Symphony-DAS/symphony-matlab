classdef ObjectSet < handle
    
    properties (SetAccess = private)
        size
    end
    
    properties (Access = protected)
        objects
    end
    
    methods
        
        function obj = ObjectSet(objects)
            if nargin < 1 || isempty(objects)
                objects = {};
            end
            if ~iscell(objects)
                objects = {objects};
            end
            obj.objects = objects;
        end     
        
        function s = get.size(obj)
            s = numel(obj.objects);
        end
        
        function e = get(obj, index)
            e = obj.objects{index};
        end
        
    end
    
    methods (Access = protected)
        
        function m = intersectMaps(obj, maps)
            m = containers.Map();
            if isempty(maps)
                return;
            end
            
            keys = maps{1}.keys;
            for i = 2:numel(obj.objects)
                keys = intersect(keys, maps{i}.keys);
            end
            
            values = cell(1, numel(keys));
            for i = 1:numel(keys)
                k = keys{i};
                v = {};
                for j = 1:numel(obj.objects)
                    p = maps{j}(k);
                    if ~any(cellfun(@(c)isequal(c, p), v))
                        v{end + 1} = p; %#ok<AGROW>
                    end
                end
                if numel(v) == 1
                    values{i} = v{1};
                else
                    values{i} = v;
                end
            end
            
            if ~isempty(keys)
                m = containers.Map(keys, values);
            end
        end
        
    end
    
end

