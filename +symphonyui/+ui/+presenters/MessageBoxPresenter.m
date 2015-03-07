classdef MessageBoxPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        message
        title
    end
    
    methods
        
        function obj = MessageBoxPresenter(message, title, view)
            if nargin < 3
                view = symphonyui.ui.views.MessageBoxView([]);
            end
            
            obj = obj@symphonyui.ui.Presenter([], view);
            obj.addListener(view, 'Ok', @obj.onViewSelectedOk);
            
            obj.message = message;
            obj.title = title;
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.ui.Presenter(obj);
            
            obj.view.setTitle(obj.title);
            obj.view.setMessage(obj.message);
        end
        
    end
    
    methods (Access = private)
        
        function onViewSelectedOk(obj, ~, ~)
            obj.view.close();
        end
        
    end
    
end

