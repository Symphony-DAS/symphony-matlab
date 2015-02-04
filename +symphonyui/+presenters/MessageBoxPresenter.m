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
            
            obj.addListener(view, 'Ok', @(h,d)obj.view.close());
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.Presenter(obj);
            
            obj.view.setTitle(obj.title);
            obj.view.setMessage(obj.message);
        end
        
    end
    
    methods (Static)
        
        function obj = showException(x)
            report = getReport(x, 'basic', 'hyperlinks', 'off');
            obj = symphonyui.presenters.MessageBoxPresenter(report, 'Error');
            obj.view.position = symphonyui.utilities.screenCenter(450, 100);
            obj.view.showDialog();
        end
        
    end
    
end

