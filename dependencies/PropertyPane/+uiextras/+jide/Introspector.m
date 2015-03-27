classdef Introspector < handle
    
    properties
        className
        descriptors
    end
    
    methods
        
        function obj = Introspector(className)
            obj.introspectProperties(className);
        end
        
        function introspectProperties(obj, className)
            obj.className = className;
            obj.descriptors = uiextras.jide.PropertyDescriptor.empty(0, 1);
            
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
                
                obj.descriptors(end + 1) = uiextras.jide.PropertyDescriptor( ...
                    'Name', mpo.Name, ...
                    'Description', comment);
            end
        end
        
        function l = createPropertyList(obj, instance)
            if ~isa(instance, obj.className)
                error('Class mismatch');
            end
            
            l = PropertyGridField.empty(0, 1);
            
            for i = 1:numel(obj.descriptors)
                d = obj.descriptors(i);
                
                name = d.Name;
                value = instance.(name);
                description = d.Description;
                
                property = PropertyGridField(name, value, ...
                    'Description', description);
                l(end + 1) = property;
            end
        end
        
    end
    
end

