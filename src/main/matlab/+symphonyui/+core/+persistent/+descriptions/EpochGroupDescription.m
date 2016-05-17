classdef EpochGroupDescription < symphonyui.core.persistent.descriptions.EntityDescription
    % An EpochGroupDescription describes the metadata of an epoch group within an experiment.
    %
    % EpochGroupDescription Methods:
    %   addAllowableParentType  - Adds an allowable parent type (class name) for the described epoch group
    %
    % See also: EntityDescription
    
    properties
        label   % Label to assign to the epoch group
    end
    
    properties (Access = private)
        allowableParentTypes    % Cell array of allowable parent class names for the epoch group
    end
    
    methods
        
        function obj = EpochGroupDescription()
            split = strsplit(class(obj), '.');
            obj.label = appbox.humanize(split{end});
        end
        
        function set.label(obj, l)
            validateattributes(l, {'char'}, {'nonempty', 'row'});
            obj.label = l;
        end
        
        function addAllowableParentType(obj, t)
            % Adds an allowable parent type (class name) for the described epoch group. An empty class name means the
            % epoch group can be top level.
            
            if ~isempty(t)
                validateattributes(t, {'char'}, {'nonempty', 'row'});
            end
            obj.allowableParentTypes{end + 1} = t;
        end
        
        function t = getAllowableParentTypes(obj)
            t = obj.allowableParentTypes;
        end
        
    end
    
end

