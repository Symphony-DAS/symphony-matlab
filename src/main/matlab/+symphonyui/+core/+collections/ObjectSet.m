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
        
        function c = intersect(obj, a, b) %#ok<INUSL>
            keep = false(1, numel(a));
            for i = 1:numel(a)
                for k = numel(b):-1:1
                    if isequal(a(i), b(k))
                        keep(i) = true;
                        b(k) = [];
                        break;
                    end
                end
            end
            c = a(keep);
        end
        
        function c = intersectMaps(obj, a, b, unionValues) %#ok<INUSL>
            if nargin < 4
                unionValues = false;
            end
            
            keys = intersect(a.keys, b.keys);

            values = cell(1, numel(keys));
            for i = 1:numel(keys)
                k = keys{i};
                if isequal(a(k), b(k))
                    values{i} = a(k);
                elseif unionValues
                    values{i} = [a(k) b(k)];
                else
                    values{i} = [];
                end
            end

            if isempty(keys)
                c = containers.Map();
            else
                c = containers.Map(keys, values);
            end
        end
        
    end
    
end

