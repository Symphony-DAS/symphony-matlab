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
            obj.view.setWindowStyle('modal');
            
            obj.documentationService = documentationService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.populateFromConfig();
            obj.populateDescriptionList();
        end
        
        function onGo(obj)
            obj.view.requestNameFocus();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'BrowseLocation', @obj.onViewSelectedBrowseLocation);
            obj.addListener(v, 'Ok', @obj.onViewSelectedOk);
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
        
        function populateDescriptionList(obj)
            classNames = obj.documentationService.getAvailableFileDescriptions();
            
            displayNames = cell(1, numel(classNames));
            for i = 1:numel(classNames)
                split = strsplit(classNames{i}, '.');
                displayNames{i} = symphonyui.core.util.humanize(split{end});
            end
            
            obj.view.setDescriptionList(displayNames, classNames);
            obj.view.setSelectedDescription(classNames{end});
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedOk();
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
        
        function onViewSelectedOk(obj, ~, ~)
            obj.view.update();
            
            name = obj.view.getName();            
            location = obj.view.getLocation();
            description = obj.view.getSelectedDescription();
            try
                obj.documentationService.newFile(name, location, description);
            catch x
                obj.view.showError(x.message);
                return;
            end
            
            obj.result = true;
            obj.close();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.close();
        end
        
    end
    
end
