classdef Protocol < handle

    properties (Hidden)
        rig
    end

    methods

        function n = getDisplayName(obj)
            split = strsplit(class(obj), '.');
            n = symphonyui.core.util.humanize(split{end});
        end

        function setRig(obj, rig)
            obj.rig = rig;
        end

        function p = getParameters(obj)
            p = struct();

            meta = metaclass(obj);
            for i = 1:numel(meta.Properties)
                property = meta.Properties{i};
                if property.Abstract || property.Hidden || ~strcmp(property.GetAccess, 'public');
                    continue;
                end
                p.(property.Name) = obj.(property.Name);
            end
        end

        function [tf, msg] = isValid(obj)
            % Returns true if this protocol is fully configured and ready to run.
            if isempty(obj.rig)
                tf = false;
                msg = 'Rig is not set';
                return;
            end

            tf = true;
            msg = [];
        end

    end

end
