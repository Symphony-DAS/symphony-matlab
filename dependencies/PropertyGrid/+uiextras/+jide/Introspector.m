classdef Introspector < handle

    properties (Access = private)
        ClassName
        StaticDescriptors
        HasDynamicDescriptors
    end

    methods

        function obj = Introspector(className)
            obj.IntrospectProperties(className);
        end

        function IntrospectProperties(obj, className)
            obj.ClassName = className;
            obj.StaticDescriptors = struct();

            clazz = meta.class.fromName(className);

            for i = 1:numel(clazz.Properties)
                mpo = clazz.Properties{i};

                % Do not include abstract, hidden, or private properties.
                if mpo.Abstract || mpo.Hidden || ~strcmp(mpo.GetAccess, 'public')
                    continue;
                end

                comment = uiextras.jide.helptext([obj.ClassName '.' mpo.Name]);
                if ~isempty(comment)
                    comment{1} = strtrim(regexprep(comment{1}, ['^' mpo.Name ' - '], ''));
                    comment = strjoin(comment, '\n');
                end

                obj.StaticDescriptors.(mpo.Name) = uiextras.jide.PropertyDescriptor( ...
                    'Name', mpo.Name, ...
                    'DisplayName', mpo.Name, ...
                    'Description', comment, ...
                    'ReadOnly', mpo.Constant || ~strcmp(mpo.SetAccess, 'public') || mpo.Dependent && isempty(mpo.SetMethod), ...
                    'Dependent', mpo.Dependent, ...
                    'Hidden', mpo.Hidden);
            end

            obj.HasDynamicDescriptors = any(cellfun(@(c)strcmp(c.Name, 'getPropertyDescriptor'), clazz.Methods));
        end

        function [l, exceptions] = CreatePropertyList(obj, instance)
            exceptions = MException.empty(0, 1);

            if ~isa(instance, obj.ClassName)
                error('Class mismatch');
            end

            l = uiextras.jide.PropertyGridField.empty(0, 1);

            names = fields(obj.StaticDescriptors);
            for i = 1:numel(names)
                desc = obj.StaticDescriptors.(names{i});

                if obj.HasDynamicDescriptors
                    try
                        desc = merge(desc, instance.getPropertyDescriptor(names{i}));
                    catch x
                        exceptions(end + 1) = x; %#ok<AGROW>
                    end
                end

                p = uiextras.jide.PropertyGridField(desc.Name, instance.(desc.Name), ...
                    'DisplayName', desc.DisplayName, ...
                    'Description', desc.Description, ...
                    'ReadOnly', desc.ReadOnly, ...
                    'Dependent', desc.Dependent, ...
                    'Hidden', desc.Hidden);
                if ~isempty(desc.Category)
                    set(p, 'Category', desc.Category);
                end
                l(end + 1) = p;
            end
        end

    end

end

function d1 = merge(d1, d2)
    if strcmp(d1.Name, d2.Name)
        error('Name mismatch');
    end
    names = fields(d2);
    for i = 1:numel(names)
        n = names{i};
        if ~isempty(d2.(n))
            d1.(n) = d2.(n);
        end
    end
end
