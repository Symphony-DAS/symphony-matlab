classdef Presenter < symphonyui.util.mixin.Observer
    
    properties (SetAccess = private)
        log
        app
        view
    end
    
    methods
        
        function obj = Presenter(app, view)
            obj.log = symphonyui.util.logging.LogManager.getLogger(class(obj));
            obj.app = app;
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

