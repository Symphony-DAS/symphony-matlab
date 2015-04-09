classdef IdGenerator < handle
    
    properties
        ids
    end
    
    methods
        
        function obj = IdGenerator()
            obj.ids = {};
        end
        
        function id = generateId(obj, prefix)
            id = prefix;
            i = 1;
            while any(strcmp(obj.ids, id))
                id = [prefix num2str(i)];
                i = i + 1;
            end
            obj.ids{end + 1} = id;
        end
        
    end
    
end

