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
            i = 0;
            while any(strcmp(obj.ids, id))
                i = i + 1;
                id = [prefix '_' num2str(i)];
            end
            obj.ids{end + 1} = id;
        end
        
    end
    
end

