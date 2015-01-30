classdef MessageBoxPresenter < symphonyui.Presenter

    methods
        
        function obj = MessageBoxPresenter(message, title, view)
            if nargin < 3
                view = symphonyui.views.MessageBoxView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.addListener(view, 'Ok', @(h,d)obj.view.close());
            
            obj.view.setTitle(title);
            obj.view.setMessage(message);
        end
        
        function setSize(obj, w, h)
            obj.view.position = symphonyui.utilities.screenCenter(w, h);
        end
        
    end
    
    methods (Static)
        
        function obj = showException(x)
            report = getReport(x, 'basic', 'hyperlinks', 'off');
            obj = symphonyui.presenters.MessageBoxPresenter(report, 'Error');
            obj.setSize(450, 100);
            obj.view.showDialog();
        end
        
    end
    
end

