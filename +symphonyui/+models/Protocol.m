classdef Protocol < handle
    
    properties (Constant, Abstract)
        displayName
    end
    
    methods
        
        function obj = Protocol()
        end
        
        function p = parameters(obj)
            import symphonyui.models.*;
            
            p = struct();
            clazz = metaclass(obj);
            for i = 1:numel(clazz.Properties)
                property = clazz.Properties{i};
                if property.Abstract || property.Hidden || ~strcmp(property.GetAccess, 'public')
                    continue;
                end
                name = property.Name;
                try
                    value = obj.(name);
                catch
                    continue;
                end
                type = [];
                if iscellstr(value)
                    type = ParameterType('char', 'row', value);
                    value = value{1};
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
                readOnly = property.Constant || ~strcmp(property.SetAccess, 'public') || property.Dependent && isempty(property.SetMethod);
                dependent = property.Dependent;
                
                parameter = Parameter(name, obj.(name), ...
                    'type', type, ...
                    'value', value, ...
                    'units', units, ...
                    'description', description, ...
                    'readOnly', readOnly, ...
                    'dependent', dependent);
                p.(name) = parameter;
            end
        end
        
    end
    
end

