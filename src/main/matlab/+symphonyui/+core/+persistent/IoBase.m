classdef IoBase < symphonyui.core.persistent.Entity

    properties (SetAccess = private)
        device
        epoch
    end

    methods

        function obj = IoBase(cobj)
            obj@symphonyui.core.persistent.Entity(cobj);
        end

        function d = get.device(obj)
            d = symphonyui.core.persistent.Device(obj.cobj.Device);
        end
        
        function b = get.epoch(obj)
            b = symphonyui.core.persistent.Epoch(obj.cobj.Epoch);
        end

    end

end
