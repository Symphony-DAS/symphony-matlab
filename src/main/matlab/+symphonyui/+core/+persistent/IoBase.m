classdef IoBase < symphonyui.core.persistent.Entity

    properties (SetAccess = private)
        device
    end

    methods

        function obj = IoBase(cobj, entityFactory)
            obj@symphonyui.core.persistent.Entity(cobj, entityFactory);
        end

        function d = get.device(obj)
            d = obj.entityFactory.fromCoreEntity(obj.cobj.Device);
        end

    end

end
