classdef Protocol < handle
    
    properties (Constant, Abstract)
        displayName     % A descriptive name for this protocol.
    end
    
    properties (Hidden)
        rig         
    end
    
    methods
        
        function set.rig(obj, r)
            if ~isempty(obj.rig)
                error('Rig is already set');
            end
            obj.rig = r;
        end
        
        function p = parameters(obj)
            % Returns a struct of this protocols parameters. 
            % See also symphonyui.models.Parameter.
            import symphonyui.models.*;
            
            p = struct();
            
            % Create a parameter from each protocol property.
            clazz = metaclass(obj);
            for i = 1:numel(clazz.Properties)
                property = clazz.Properties{i};
                
                % Do not include abstract, hidden, or private properties.
                if property.Abstract || property.Hidden || ~strcmp(property.GetAccess, 'public')
                    continue;
                end
                
                name = property.Name;
                value = obj.(name);
                
                % Use the property default value to try to determine the parameter type.
                defaultValue = [];
                if property.HasDefault
                    defaultValue = property.DefaultValue;
                end
                type = ParameterType.autoDiscover(defaultValue);
                
                % Parse the property comment to determine the parameter description and units.
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
                
                % Create and add the parameter to the struct.
                parameter = Parameter(name, value, ...
                    'type', type, ...
                    'units', units, ...
                    'description', description, ...
                    'isReadOnly', isReadOnly, ...
                    'isDependent', isDependent);
                p.(name) = parameter;
            end
        end
        
        function [tf, msg] = isValid(obj)
            % Returns true if this protocol is fully configured to run.
            if isempty(obj.rig)
                tf = false;
                msg = 'Rig is not set';
                return;
            end
            
            parameters = struct2cell(obj.parameters());
            for i = 1:numel(parameters)
                if ~parameters{i}.isValid
                    tf = false;
                    msg = [parameters{i}.displayName ' is not valid'];
                    return;
                end
            end
            
            [tf, msg] = obj.rig.isValid();
        end
        
    end
    
end

