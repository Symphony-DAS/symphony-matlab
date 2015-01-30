classdef MessageBoxPresenter < symphonyui.Presenter
    
    properties
    end
    
    methods
        
        function obj = MessageBoxPresenter(message, title, view)
            if nargin < 3
                view = symphonyui.views.MessageBoxView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            
            obj.view.setTitle(title);
            obj.view.setMessage(message);
        end
        
        function onSelectedOk(obj, ~, ~)
            obj.view.close();
        end
        
    end
    
    methods (Static)
        
        function obj = showException(x)
            import symphonyui.presenters.*;
            obj = MessageBoxPresenter.showError(getReport(x, 'basic', 'hyperlinks', 'off'));
        end
        
        function obj = showError(msg)
            import symphonyui.presenters.*;
            obj = MessageBoxPresenter(msg, 'Error');
            obj.view.showDialog();
        end
        
    end
    
end

