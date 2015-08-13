classdef Device < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        name
        manufacturer
    end
    
    methods
        
        function obj = Device(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end

        function m = get.manufacturer(obj)
            m = char(obj.cobj.Manufacturer);
        end
        
        function d = bindStream(obj, stream)
            obj.tryCore(@()obj.cobj.BindStream(stream.cobj));
            d = obj;
        end
        
    end
    
end

