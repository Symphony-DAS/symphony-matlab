classdef Protocol < handle
    
    properties (Constant, Abstract)
        displayName
    end
    
    properties (Hidden)
        rig
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
                isReadOnly = property.Constant || ~strcmp(property.SetAccess, 'public') || property.Dependent && isempty(property.SetMethod);
                isDependent = property.Dependent;
                
                parameter = Parameter(name, obj.(name), ...
                    'type', type, ...
                    'value', value, ...
                    'units', units, ...
                    'description', description, ...
                    'isReadOnly', isReadOnly, ...
                    'isDependent', isDependent);
                p.(name) = parameter;
            end
        end
        
        function [tf, msg] = isValid(obj)
            if isempty(obj.rig)
                tf = false;
                msg = 'Protocol rig is not set';
                return;
            end
            
            parameters = struct2cell(obj.parameters());
            for i = 1:numel(parameters)
                if ~parameters{i}.isValid
                    tf = false;
                    msg = 'One or more parameters is not valid';
                    return;
                end
            end
            
            [tf, msg] = obj.rig.isValid();
        end
        
    end
    
end

