classdef Protocol < handle
    
    properties (Hidden)
        displayName
    end
    
    methods
        
        function obj = Protocol()
            split = strsplit(class(obj), '.');
            obj.displayName = symphonyui.core.util.humanize(split{end});
        end
        
        function set.displayName(obj, n)
            validateattributes(n, {'char'}, {'nonempty', 'row'});
            obj.displayName = n;
        end
        
        function d = getPropertyDescriptors(obj)
            d = symphonyui.core.util.introspect(obj);
        end
        
        function prepareRun(obj)
            
        end
        
        function prepareEpoch(obj, epoch)
            
        end
        
        function completeEpoch(obj, epoch)
            
        end
        
        function tf = continueRun(obj)
            tf = true;
        end
        
        function completeRun(obj)
            
        end

        function [tf, msg] = isValid(obj)
            tf = true;
            msg = [];
        end

    end

end
