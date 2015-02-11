classdef EndEpochGroupPresenter < symphonyui.Presenter
    
    properties (Access = private)
        appController
    end
    
    properties (Access = private)
        preferences = symphonyui.app.Preferences.getDefault();
    end
    
    methods
        
        function obj = EndEpochGroupPresenter(appController, view)
            if nargin < 2
                view = symphonyui.views.EndEpochGroupView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.appController = appController;
            
            obj.addListener(view, 'End', @obj.onSelectedEnd);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.Presenter(obj);
            
        end
        
    end
    
    methods (Access = private)
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedEnd();
            elseif strcmp(data.Key, 'escape')
                obj.view.close();
            end
        end
        
        function onSelectedEnd(obj, ~, ~)
            drawnow();
            
            try
                obj.appController.endEpochGroup();
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.view.result = true;
        end
        
    end
    
end
