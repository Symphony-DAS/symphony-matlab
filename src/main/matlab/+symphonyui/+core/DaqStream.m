classdef DaqStream < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        name
    end
    
    methods
        
        function obj = DaqStream(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end
        
    end
    
end

