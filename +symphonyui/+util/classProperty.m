function v = classProperty(className, propertyName)
    v = [];
    
    mcls = meta.class.fromName(className);
    if isempty(mcls)
        return;
    end
    
    props = mcls.PropertyList;
    for i = 1:length(props)
        prop = props(i);
        if strcmp(prop.Name, propertyName)
            v = prop.DefaultValue;
            break;
        end
    end
end