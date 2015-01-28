classdef Protocol < handle
    
    properties (Constant, Abstract)
        displayName
    end
    
    methods
        
        function obj = Protocol()
        end
        
        function p = parameters(obj)
            p = struct();
            clazz = metaclass(obj);
            for i = 1:numel(clazz.Properties)
                property = clazz.Properties{i};
                if property.Abstract || property.Constant || property.Hidden || ~strcmp(property.GetAccess, 'public')
                    continue;
                end
                name = property.Name;
                try
                    value = obj.(name);
                catch
                    continue;
                end
                comment = helptext([clazz.Name '.' name]);
                if ~isempty(comment)
                    [~, comment] = strtok(comment{1}, '-');
                    [match, start] = regexp(comment, '\(([^)]+)\)', 'match', 'start');
                    if isempty(match)
                        match = {'()'};
                        start = length(comment) + 1;
                    end
                    description = strtrim(comment(2:start(end)-1));
                    units = match{end}(2:end-1);
                else
                    description = [];
                    units = [];
                end
                readOnly = ~strcmp(property.SetAccess, 'public') || property.Dependent && isempty(property.SetMethod);
                dependent = property.Dependent;
                
                parameter = symphonyui.models.Parameter(name, obj.(name));
                parameter.value = value;
                parameter.units = units;
                parameter.description = description;
                parameter.readOnly = readOnly;
                parameter.dependent = dependent;
                p.(name) = parameter;
            end
        end
        
    end
    
end

