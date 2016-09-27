classdef SplitEpochGroupView < appbox.View
    
    properties
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Split Epoch Group', ...
                'Position', screenCenter(300, 169));
        end
        
    end
    
end

