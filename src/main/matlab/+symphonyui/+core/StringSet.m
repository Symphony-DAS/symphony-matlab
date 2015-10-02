classdef StringSet < handle
    
    properties (SetAccess = private)
        set
        type
    end
    
    methods
        
        function obj = StringSet(set)
            if ~iscellstr(set)
                error('Set must be a cellstr');
            end
            obj.set = set;
        end
        
        function v = firstOrEmpty(obj)
            if isempty(obj.set)
                v = [];
            else
                v = obj.set{1};
            end
        end
        
        function t = get.type(obj)
            if isempty(obj.set)
                t = symphonyui.core.PropertyType('denserealdouble', 'empty');
            else
                t = symphonyui.core.PropertyType('char', 'row', obj.set);
            end
        end
        
    end
    
end

