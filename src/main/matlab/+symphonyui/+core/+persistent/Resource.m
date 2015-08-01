classdef Resource < symphonyui.core.persistent.Entity

    properties (SetAccess = private)
        uti
        name
        data
    end

    methods

        function obj = Resource(cobj)
            obj@symphonyui.core.persistent.Entity(cobj);
        end
        
        function n = get.uti(obj)
            n = char(obj.cobj.UTI);
        end

        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end
        
        function d = get.data(obj)
            d = uint8(obj.cobj.Data);
        end

    end

end
