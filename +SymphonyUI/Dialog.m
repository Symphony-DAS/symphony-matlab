classdef Dialog < SymphonyUI.View
    
    methods
        
        function obj = Dialog(presenter)
            obj = obj@SymphonyUI.View(presenter);
        end
        
        function show(obj)
            show@SymphonyUI.View(obj);
            uiwait(obj.figureHandle);
        end
        
        function hide(obj)
            hide@SymphonyUI.View(obj);
            uiresume(obj.figureHandle);
        end
        
    end
    
end

