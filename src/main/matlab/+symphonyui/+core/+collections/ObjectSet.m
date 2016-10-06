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
    
end

