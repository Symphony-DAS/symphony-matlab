classdef NewExperimentPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        acquisitionService
    end
    
    methods
        
        function obj = NewExperimentPresenter(acquisitionService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.NewExperimentView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.acquisitionService = acquisitionService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            config = obj.app.config;
            name = config.get(symphonyui.app.Settings.EXPERIMENT_DEFAULT_NAME);
            location = config.get(symphonyui.app.Settings.EXPERIMENT_DEFAULT_LOCATION);
            try
                obj.view.setName(name());
                obj.view.setLocation(location());
            catch x
                msg = ['Unable to set view from config: ' x.message];
                obj.log.debug(msg, x);
                obj.view.showError(msg);
            end
        end
        
        function onGo(obj)
            obj.view.requestPurposeFocus();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'BrowseLocation', @obj.onViewSelectedBrowseLocation);
            obj.addListener(v, 'Open', @obj.onViewSelectedOpen);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
        
    end
    
    methods (Access = private)
        
        function onViewKeyPress(obj, ~, data)
            switch data.key
                case 'return'
                    obj.onViewSelectedOpen();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedBrowseLocation(obj, ~, ~)
            location = uigetdir(pwd, 'Experiment Location');
            if location ~= 0
                obj.view.setLocation(location);
            end
        end
        
        function onViewSelectedOpen(obj, ~, ~)
            obj.view.update();
            
            name = obj.view.getName();            
            location = obj.view.getLocation();
            purpose = obj.view.getPurpose();
            
            try
                obj.acquisitionService.createExperiment(name, location, purpose);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.view.hide();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.view.hide();
        end
        
    end
    
end
