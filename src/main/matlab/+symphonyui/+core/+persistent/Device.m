classdef Device < symphonyui.core.persistent.Entity
    
    properties (SetAccess = private)
        name
        manufacturer
    end
    
    methods
        
        function obj = Device(cobj)
            obj@symphonyui.core.persistent.Entity(cobj);
        end
        
        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end
        
        function m = get.manufacturer(obj)
            m = char(obj.cobj.Manufacturer);
        end
        
    end
    
end

