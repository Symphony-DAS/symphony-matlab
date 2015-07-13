classdef NewFilePresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
    end
    
    methods
        
        function obj = NewFilePresenter(documentationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.NewFileView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.documentationService = documentationService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.populateFromConfig();
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
        
        function populateFromConfig(obj)
            import symphonyui.app.Options;
            
            config = obj.app.config;
            name = config.get(Options.FILE_DEFAULT_NAME);
            location = config.get(Options.FILE_DEFAULT_LOCATION);
            try
                obj.view.setName(name());
                obj.view.setLocation(location());
            catch x
                msg = ['Unable to populate view from config: ' x.message];
                obj.log.debug(msg, x);
                obj.view.showError(msg);
            end
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.key
                case 'return'
                    % FIXME: Not sure why this is being called twice when return is hit.
                    %obj.onViewSelectedOpen();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedBrowseLocation(obj, ~, ~)
            location = obj.view.showGetFile(pwd, 'File Location');
            if location == 0
                return;
            end
            obj.view.setLocation(location);
        end
        
        function onViewSelectedOpen(obj, ~, ~)
            obj.view.update();
            
            name = obj.view.getName();            
            location = obj.view.getLocation();
            try
                obj.documentationService.createFile(name, location);
            catch x
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
