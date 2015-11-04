classdef NewFilePresenter < appbox.Presenter

    properties (Access = private)
        log
        settings
        documentationService
    end

    methods

        function obj = NewFilePresenter(documentationService, view)
            if nargin < 3
                view = symphonyui.ui.views.NewFileView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.NewFileSettings();
            obj.documentationService = documentationService;
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateName();
            obj.populateLocation();
            obj.populateDescriptionList();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
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

        function populateName(obj)
            name = symphonyui.app.Options.getDefault().fileDefaultName;
            try
                obj.view.setName(name());
            catch x
                obj.log.debug(['Unable to populate name: ' x.message], x);
            end
        end

        function populateLocation(obj)
            location = symphonyui.app.Options.getDefault().fileDefaultLocation;
            try
                obj.view.setLocation(location());
            catch x
                obj.log.debug(['Unable to populate location: ' x.message], x);
            end
        end

        function populateDescriptionList(obj)
            classNames = obj.documentationService.getAvailableExperimentDescriptions();

            displayNames = cell(1, numel(classNames));
            for i = 1:numel(classNames)
                split = strsplit(classNames{i}, '.');
                displayNames{i} = symphonyui.core.util.humanize(split{end});
            end

            if numel(classNames) > 0
                obj.view.setDescriptionList(displayNames, classNames);
            else
                obj.view.setDescriptionList({'(None)'}, {[]});
            end
            obj.view.enableOk(numel(classNames) > 0);
            obj.view.enableSelectDescription(numel(classNames) > 0);
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
            location = obj.view.showGetDirectory('Select Location');
            if isempty(location)
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
                path = obj.documentationService.getFilePath(name, location);
                if exist(path, 'file')
                    [~, n, e] = fileparts(path);
                    filename = [n e];
                    result = obj.view.showMessage(['''' filename ''' already exists. Overwrite?'], ...
                        'Overwrite File', ...
                        'Cancel', 'Overwrite');
                    if ~strcmp(result, 'Overwrite')
                        return;
                    end
                    delete(path);
                    if exist(path, 'file')
                        error(['Unable to delete ''' filename '''']);
                    end
                end
                obj.documentationService.newFile(name, location, description);
            catch x
                obj.view.showError(x.message);
                return;
            end
            
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save presenter settings: ' x.message], x);
            end

            obj.result = true;
            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
        function loadSettings(obj)
            if any(strcmp(obj.settings.selectedDescription, obj.view.getDescriptionList()))
                obj.view.setSelectedDescription(obj.settings.selectedDescription);
            end
        end

        function saveSettings(obj)
            obj.settings.selectedDescription = obj.view.getSelectedDescription();
            obj.settings.save();
        end

    end

end
