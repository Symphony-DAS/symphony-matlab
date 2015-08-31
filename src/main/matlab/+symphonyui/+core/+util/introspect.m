function d = introspect(obj)
    d = symphonyui.core.PropertyDescriptor.empty(0, 1);
    
    meta = metaclass(obj);
    names = {meta.PropertyList.Name};
    for i = 1:numel(meta.PropertyList)
        mpo = meta.PropertyList(i);
        if mpo.Abstract || mpo.Hidden || ~strcmp(mpo.GetAccess, 'public');
            continue;
        end
        
        comment = uiextras.jide.helptext([class(obj) '.' mpo.Name]);
        if ~isempty(comment)
            comment{1} = strtrim(regexprep(comment{1}, ['^' mpo.Name ' -'], ''));
        end
        comment = strjoin(comment, '\n');
        
        descriptor = symphonyui.core.PropertyDescriptor(mpo.Name, obj.(mpo.Name), ...
            'description', comment, ...
            'readOnly', mpo.Constant || ~strcmp(mpo.SetAccess, 'public') || mpo.Dependent && isempty(mpo.SetMethod));
        
        mto = meta.PropertyList(strcmp([mpo.Name 'Type'], names));
        if ~isempty(mto) && mto.Hidden && isa(obj.(mto.Name), 'symphonyui.core.PropertyType')
            descriptor.type = obj.(mto.Name);
        end
        
        d(end + 1) = descriptor; %#ok<AGROW>
    end
end

