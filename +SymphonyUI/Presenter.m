classdef Presenter < handle
    
    properties
        view
    end
    
    methods
        
        function obj = Presenter()
        end
        
        function onSelectedClose(obj, ~, ~)
            obj.view.close();
        end
        
    end
    
end

