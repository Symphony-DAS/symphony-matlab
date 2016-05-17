classdef SourceDescription < symphonyui.core.persistent.descriptions.EntityDescription
    % An SourceDescription describes the metadata of a source within an experiment.
    %
    % SourceDescription Methods:
    %   addAllowableParentType  - Adds an allowable parent type (class name) for the described source
    %
    % See also: EntityDescription
    
    properties
        label
    end
    
    properties (Access = private)
        allowableParentTypes
    end
    
    methods

        function obj = SourceDescription()
            split = strsplit(class(obj), '.');
            obj.label = appbox.humanize(split{end});
        end
        
        function set.label(obj, l)
            validateattributes(l, {'char'}, {'nonempty', 'row'});
            obj.label = l;
        end
        
        function addAllowableParentType(obj, t)
            % Adds an allowable parent type (class name) for the described source. An empty class name means the
            % source can be top level.
            
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

