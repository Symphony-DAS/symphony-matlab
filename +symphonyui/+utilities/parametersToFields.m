function fields = parametersToFields(parameters)
    if isempty(parameters)
        fields = PropertyGridField.empty(1,0);
        return;
    end
    
    if ~iscell(parameters)
        parameters = {parameters};
    end
    
    fields = [];
    for i = 1:numel(parameters)
        p = parameters{i};
        
        description = p.description;
        if ~isempty(p.units)
            description = [description ' (' p.units ')'];
        end

        f = PropertyGridField(p.name, p.value, ...
            'DisplayName', p.displayName, ...
            'Description', description, ...
            'ReadOnly', p.isReadOnly, ...
            'Dependent', p.isDependent);
        if ~isempty(p.type)
            set(f, 'Type', PropertyType(p.type.primitiveType, p.type.shape, p.type.domain));
        end
        if ~isempty(p.category)
            set(f, 'Category', p.category);
        end
        fields = [fields f];
    end
end

