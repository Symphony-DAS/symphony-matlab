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
                end
                comment = strjoin(comment, '\n');
                
                obj.StaticDescriptors.(mpo.Name) = uiextras.jide.PropertyDescriptor(mpo.Name, ...
                    'DisplayName', mpo.Name, ...
                    'Description', comment, ...
                    'ReadOnly', mpo.Constant || ~strcmp(mpo.SetAccess, 'public') || mpo.Dependent && isempty(mpo.SetMethod), ...
                    'Hidden', mpo.Hidden);
            end

            obj.HasDynamicDescriptors = any(cellfun(@(c)strcmp(c.Name, 'getPropertyDescriptor'), clazz.Methods));
        end

        function l = CreatePropertyList(obj, instance)
            if ~isa(instance, obj.ClassName)
                error('Class mismatch');
            end

            l = uiextras.jide.PropertyGridField.empty(0, 1);

            names = fields(obj.StaticDescriptors);
            for i = 1:numel(names)
                try
                    l(end + 1) = obj.CreateProperty(instance, names{i});
                catch x
                    e = MException('Instrospector:CannotCreateProperty', ...
                        'Unable to create property for ''%s'':\n%s', names{i}, x.message);
                    throw(e);
                end
            end
        end
        
    end
    
    methods (Access = private)
        
        function p = CreateProperty(obj, instance, name)
            desc = obj.StaticDescriptors.(name);
            
            if obj.HasDynamicDescriptors
                desc = merge(desc, instance.getPropertyDescriptor(name));
            end
            
            p = uiextras.jide.PropertyGridField(name, instance.(name), ...
                'DisplayName', desc.DisplayName, ...
                'Description', desc.Description, ...
                'ReadOnly', desc.ReadOnly, ...
                'Hidden', desc.Hidden);
            if ~isempty(desc.Category)
                p.Category = desc.Category;
            end
            if ~isempty(desc.Domain)
                p.Type.Domain = desc.Domain;
            end
        end

    end

end

function d1 = merge(d1, d2)
    if ~strcmp(d1.Name, d2.Name)
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
