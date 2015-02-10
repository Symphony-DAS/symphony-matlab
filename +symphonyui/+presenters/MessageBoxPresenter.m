classdef MessageBoxPresenter < symphonyui.Presenter
    
    properties (Access = private)
        message
        title
    end
    
    methods
        
        function obj = MessageBoxPresenter(message, title, view)
            if nargin < 3
                view = symphonyui.views.MessageBoxView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.message = message;
            obj.title = title;
            
            obj.addListener(view, 'Ok', @(h,d)obj.views.close());
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.Presenter(obj);
            
            obj.views.setTitle(obj.title);
            obj.views.setMessage(obj.message);
        end
        
    end
    
    methods (Static)
        
        function obj = showException(x)
            obj = symphonyui.presenters.MessageBoxPresenter(x.message, 'Error');
            obj.views.position = symphonyui.util.screenCenter(450, 85);
            obj.views.showDialog();
        end
        
    end
    
end

