classdef ExperimentSet < symphonyui.core.persistent.collections.TimelineEntitySet

    properties
        purpose
    end

    methods

        function obj = ExperimentSet(experiments)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(experiments);
        end

        function p = createPreset(obj, name)
            p = symphonyui.core.persistent.ExperimentPreset(name, obj.getDescriptionType(), obj.getProperties(), obj.purpose);
        end

        function p = get.purpose(obj)
            p = '';
            if ~isempty(obj.objects) && all(cellfun(@(e)isequal(e.purpose, obj.objects{1}.purpose), obj.objects))
                p = obj.objects{1}.purpose;
            end
        end

        function set.purpose(obj, p)
            for i = 1:obj.size
                obj.get(i).purpose = p;
            end
        end

    end

end
