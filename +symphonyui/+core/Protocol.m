classdef Protocol < symphonyui.infra.Discoverable
    
    events (NotifyAccess = private)
        ChangedParameter
    end
    
    properties (Hidden)
        rig
    end
    
    methods
        
        function setRig(obj, rig)
            obj.rig = rig;
        end
        
        function p = getAllParameters(obj)
            clazz = metaclass(obj);
            properties = clazz.Properties;
            
            p = symphonyui.core.Parameter.empty(0, 1);
            
            for i = 1:numel(properties)
                property = clazz.Properties{i};
                
                % Do not include abstract, hidden, or private properties.
                if property.Abstract || property.Hidden || ~strcmp(property.GetAccess, 'public')
                    continue;
                end
                
                p(end + 1) = obj.getParameter(property.Name);
            end
        end
        
        function p = getParameter(obj, name)
            value = obj.(name);
            type = symphonyui.core.ParameterType.autoDiscover(value);
            
            % Parse the property comment to determine the parameter description and units.
            comment = helptext([class(obj) '.' name]);
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
            
            property = findprop(obj, name);
            isReadOnly = property.Constant || ~strcmp(property.SetAccess, 'public') || property.Dependent && isempty(property.SetMethod);
            isDependent = property.Dependent;
            
            p = symphonyui.core.Parameter(name, value, ...
                'type', type, ...
                'units', units, ...
                'description', description, ...
                'isReadOnly', isReadOnly, ...
                'isDependent', isDependent);
        end
        
        function setParameter(obj, name, value)
            obj.(name) = value;
            notify(obj, 'ChangedParameter', symphonyui.core.ParameterEventData(obj.getParameter(name)));
        end
        
        function [tf, msg] = isValid(obj)
            % Returns true if this protocol is fully configured and ready to run.
            if isempty(obj.rig)
                tf = false;
                msg = 'Rig is not set';
                return;
            end
            
            parameters = obj.getAllParameters();
            for i = 1:numel(parameters)
                if ~parameters(i).isValid
                    tf = false;
                    msg = [parameters(i).displayName ' is not valid'];
                    return;
                end
            end
            
            tf = true;
            msg = [];
        end
        
    end
    
end

