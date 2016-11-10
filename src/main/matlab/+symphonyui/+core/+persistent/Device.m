classdef Device < symphonyui.core.persistent.Entity

    properties (SetAccess = private)
        name
        manufacturer
        experiment
    end

    methods

        function obj = Device(cobj, factory)
            obj@symphonyui.core.persistent.Entity(cobj, factory);
        end

        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end

        function m = get.manufacturer(obj)
            m = char(obj.cobj.Manufacturer);
        end

        function e = get.experiment(obj)
            e = obj.entityFactory.create(obj.cobj.Experiment);
        end

    end

end
