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
        
        function d = getPropertyDescriptors(obj)
            meta = metaclass(obj);
            d = symphonyui.core.PropertyDescriptor.empty(0, 1);
            for i = 1:numel(meta.Properties)
                property = meta.Properties{i};
                if property.Abstract || property.Hidden || ~strcmp(property.GetAccess, 'public');
                    continue;
                end
                name = property.Name;
                value = obj.(name);
                readOnly = property.Constant || ~strcmp(property.SetAccess, 'public') || property.Dependent && isempty(property.SetMethod);
                d(end + 1) = symphonyui.core.PropertyDescriptor(name, value, ...
                    'readOnly', readOnly);
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
