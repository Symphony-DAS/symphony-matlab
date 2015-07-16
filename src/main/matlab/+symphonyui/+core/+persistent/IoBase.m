classdef IoBase < symphonyui.core.persistent.Entity

    properties (SetAccess = private)
        device
    end

    methods

        function obj = IoBase(cobj)
            obj@symphonyui.core.persistent.Entity(cobj);
        end

        function d = get.device(obj)
            d = symphonyui.core.persistent.Device(obj.cobj.Device);
        end

    end

end
