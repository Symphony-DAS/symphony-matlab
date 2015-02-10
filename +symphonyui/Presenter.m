classdef Presenter < symphonyui.mixin.Observer
    
    properties (SetAccess = private)
        view
    end
    
    methods
        
        function obj = Presenter(view)
            obj.view = view;
            obj.addListener(view, 'Shown', @obj.onViewShown);
            obj.addListener(view, 'Closing', @obj.onViewClosing);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~) %#ok<INUSD>
            
        end
        
        function onViewClosing(obj, ~, ~)
            obj.removeAllListeners();
        end
        
    end
    
end

