function d = introspect(obj)
    d = symphonyui.core.PropertyDescriptor.empty(0, 1);
    
    meta = metaclass(obj);
    for i = 1:numel(meta.Properties)
        mpo = meta.Properties{i};
        if mpo.Abstract || mpo.Hidden || ~strcmp(mpo.GetAccess, 'public');
            continue;
        end
        
        comment = uiextras.jide.helptext([class(obj) '.' mpo.Name]);
        if ~isempty(comment)
            comment{1} = strtrim(regexprep(comment{1}, ['^' mpo.Name ' - '], ''));
        end
        comment = strjoin(comment, '\n');
        
        d(end + 1) = symphonyui.core.PropertyDescriptor(mpo.Name, obj.(mpo.Name), ...
            'description', comment, ...
            'readOnly', mpo.Constant || ~strcmp(mpo.SetAccess, 'public') || mpo.Dependent && isempty(mpo.SetMethod)); %#ok<AGROW>
    end
end

