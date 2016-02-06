classdef SourceDescription < symphonyui.core.persistent.descriptions.EntityDescription
    
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

