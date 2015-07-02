classdef MessageBoxPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        message
        title
    end
    
    methods
        
        function obj = MessageBoxPresenter(message, title, view)
            if nargin < 3
                view = symphonyui.ui.views.MessageBoxView();
            end
            obj = obj@symphonyui.ui.Presenter([], view);            
            obj.message = message;
            obj.title = title;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.view.setTitle(obj.title);
            obj.view.setMessage(obj.message);
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'Ok', @obj.onViewSelectedOk);
        end
        
    end
    
    methods (Access = private)
        
        function onViewSelectedOk(obj, ~, ~)
            obj.view.hide();
        end
        
    end
    
end

