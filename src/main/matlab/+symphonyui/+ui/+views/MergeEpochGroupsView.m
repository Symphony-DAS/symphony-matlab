classdef MergeEpochGroupsView < appbox.View
    
    properties
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Merge Epoch Groups', ...
                'Position', screenCenter(300, 169));
        end
        
    end
    
end

