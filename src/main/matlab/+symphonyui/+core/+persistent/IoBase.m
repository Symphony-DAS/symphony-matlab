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
        
        function m = getConfigurationMap(obj)
            m = containers.Map();
            spans = obj.cellArrayFromEnumerable(obj.cobj.ConfigurationSpans);
            for i = 1:numel(spans)
                nodes = obj.cellArrayFromEnumerable(spans{i}.Nodes);
                for k = 1:numel(nodes)
                    m = appbox.unionMaps(m, obj.mapFromKeyValueEnumerable(nodes{i}.Configuration));
                end
            end
        end

    end

end
