function parameters = fieldsToParameters(fields)
    % TODO: Convert type.

    parameters = {};    
    if isempty(fields)
        return;
    end
    
    for i = 1:numel(fields)
        f = fields(i);
        p = symphonyui.models.Parameter(f.Name, f.Value);
        
        p.category = f.Category;
        p.displayName = f.DisplayName;
        p.description = f.Description;
        p.readOnly = f.ReadOnly;
        p.dependent = f.Dependent;
        parameters{end + 1} = p;
    end
end

