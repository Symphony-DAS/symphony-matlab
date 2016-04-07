classdef EpochGroupSet < symphonyui.core.persistent.collections.TimelineEntitySet

    properties
        label
    end

    properties (SetAccess = private)
        source
    end

    methods

        function obj = EpochGroupSet(groups)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(groups);
        end

        function p = createPreset(obj, name)
            p = createPreset@symphonyui.core.persistent.collections.TimelineEntitySet(obj, name);
            p.classProperties('label') = obj.label;
        end

        function l = get.label(obj)
            l = '';
            if ~isempty(obj.objects) && all(cellfun(@(g)isequal(g.label, obj.objects{1}.label), obj.objects))
                l = obj.objects{1}.label;
            end
        end

        function set.label(obj, l)
            for i = 1:obj.size
                obj.get(i).label = l;
            end
        end

        function s = get.source(obj)
            s = [];
            if ~isempty(obj.objects) && all(cellfun(@(g)isequal(g.source, obj.objects{1}.source), obj.objects))
                s = obj.objects{1}.source;
            end
        end

    end

end
