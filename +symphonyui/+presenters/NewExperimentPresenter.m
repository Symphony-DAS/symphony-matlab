classdef NewExperimentPresenter < symphonyui.Presenter
    
    properties (Access = private)
        controller
    end
    
    methods
        
        function obj = NewExperimentPresenter(controller, view)
            if nargin < 2
                view = symphonyui.views.NewExperimentView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.controller = controller;
            
            obj.addListener(view, 'BrowseLocation', @obj.onSelectedBrowseLocation);
            obj.addListener(view, 'Open', @obj.onSelectedOpen);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)
            import symphonyui.app.Settings;
            
            onViewShown@symphonyui.Presenter(obj);
            
            exp = Settings.experiment;
            
            obj.view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            obj.view.setName(Settings.parse(exp.defaultName));
            obj.view.setPurpose(Settings.parse(exp.defaultPurpose));
            obj.view.setLocation(Settings.parse(exp.defaultLocation));
        end
        
    end
    
    methods (Access = private)
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedOpen();
            elseif strcmp(data.Key, 'escape')
                obj.view.close();
            end
        end
        
        function onSelectedBrowseLocation(obj, ~, ~)
            location = uigetdir(pwd, 'Experiment Location');
            if location ~= 0
                obj.view.setLocation(location);
            end
        end
        
        function onSelectedOpen(obj, ~, ~)
            drawnow();
            
            name = obj.view.getName();            
            location = obj.view.getLocation();
            purpose = obj.view.getPurpose();
            source = [];
            path = fullfile(location, name);
            
            try
                obj.controller.openExperiment(path, purpose, source);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.view.result = true;
        end
        
    end
    
end
