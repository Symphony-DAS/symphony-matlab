classdef Introspector < handle
    
    properties
        className
        staticDescriptors
    end
    
    methods
        
        function obj = Introspector(className)
            obj.introspectProperties(className);
        end
        
        function introspectProperties(obj, className)
            obj.className = className;
            obj.staticDescriptors = struct();
            
            clazz = meta.class.fromName(className);
            for i = 1:numel(clazz.Properties)
                mpo = clazz.Properties{i};
                
                % Do not include abstract, hidden, or private properties.
                if mpo.Abstract || mpo.Hidden || ~strcmp(mpo.GetAccess, 'public')
                    continue;
                end
                
                comment = helptext([obj.className '.' mpo.Name]);
                if ~isempty(comment)
                    comment{1} = strtrim(regexprep(comment{1}, ['^' mpo.Name ' - '], ''));
                    comment = strjoin(comment, '\n');
                end
                
                obj.staticDescriptors.(mpo.Name) = uiextras.jide.PropertyDescriptor( ...
                    'Name', mpo.Name, ...
                    'Description', comment, ...
                    'IsHidden', mpo.Hidden, ...
                    'IsEditable', ~(mpo.Constant || mpo.Dependent));
            end
        end
        
        function l = createPropertyList(obj, instance)
            if ~isa(instance, obj.className)
                error('Class mismatch');
            end
            
            l = PropertyGridField.empty(0, 1);
            
            names = fields(obj.staticDescriptors);
            for i = 1:numel(names)               
                desc = obj.staticDescriptors.(names{i});
                try %#ok<TRYNC>
                    desc = merge(desc, instance.getPropertyDescriptor(names{i}));
                end
                
                if desc.IsHidden
                    continue;
                end

                p = PropertyGridField(desc.Name, instance.(desc.Name), ...
                    'Description', desc.Description, ...
                    'ReadOnly', ~desc.IsEditable);
                if ~isempty(desc.Category)
                    set(p, 'Category', desc.Category);
                end
                l(end + 1) = p;
            end
        end
        
    end
    
end

function d1 = merge(d1, d2)
    if ~isempty(d2.Category)
        d1.Category = d2.Category;
    end
    if ~isempty(d2.Description)
        d1.Description = d2.Description;
    end
    if ~isempty(d2.IsHidden)
        d1.IsHidden = d2.IsHidden;
    end
    if ~isempty(d2.IsEditable)
        d1.IsEditable = d2.IsEditable;
    end
end