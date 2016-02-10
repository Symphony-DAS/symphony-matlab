classdef Drug < symphonyui.core.persistent.descriptions.EpochGroupDescription
    
    methods
        
        function obj = Drug()
            import symphonyui.core.*;
            
            obj.addProperty('externalSolutionAdditions', '');
            obj.addProperty('internalSolutionAdditions', '');
            
            obj.addAllowableParentType([]);
        end
        
    end
    
end

