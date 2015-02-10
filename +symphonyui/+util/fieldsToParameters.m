function parameters = fieldsToParameters(fields)
    % TODO: Parse description into description and units.
    import symphonyui.models.*;
    
    parameters = Parameter.empty(0, 1);    
    if isempty(fields)
        return;
    end
    
    for i = 1:numel(fields)
        f = fields(i);
        p = symphonyui.models.Parameter(f.Name, f.Value, ...
            'type', ParameterType(f.Type.PrimitiveType, f.Type.Shape, f.Type.Domain), ...
            'category', f.Category, ...
            'displayName', f.DisplayName, ...
            'description', f.Description, ...
            'isReadOnly', f.ReadOnly, ...
            'isDependent', f.Dependent);
        parameters(end + 1) = p;
    end
end

