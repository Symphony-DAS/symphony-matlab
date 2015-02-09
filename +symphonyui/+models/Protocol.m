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
        
        function p = getParameters(obj)
            % Returns a vector of protocol parameters.
            % See also symphonyui.models.Parameter.
            import symphonyui.models.*;
            
            clazz = metaclass(obj);
            properties = clazz.Properties;
            
            p = symphonyui.models.Parameter.empty(0, 1);
            
            % Create a parameter from each protocol property.
            for i = 1:numel(properties)
                property = clazz.Properties{i};
                
                % Do not include abstract, hidden, or private properties.
                if property.Abstract || property.Hidden || ~strcmp(property.GetAccess, 'public')
                    continue;
                end
                
                name = property.Name;
                value = obj.(name);
                type = ParameterType.autoDiscover(value);
                
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
                p(end + 1) = parameter;
            end
        end
        
        function [tf, msg] = isValid(obj)
            % Returns true if this protocol is fully configured and ready to run.
            if isempty(obj.rig)
                tf = false;
                msg = 'Rig is not set';
                return;
            end
            
            parameters = obj.getParameters();
            for i = 1:numel(parameters)
                if ~parameters(i).isValid
                    tf = false;
                    msg = [parameters(i).displayName ' is not valid'];
                    return;
                end
            end
            
            [tf, msg] = obj.rig.isValid();
        end
        
    end
    
end

