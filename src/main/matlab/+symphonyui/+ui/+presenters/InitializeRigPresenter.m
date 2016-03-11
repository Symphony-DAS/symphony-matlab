classdef InitializeRigPresenter < appbox.Presenter

    properties (Access = private)
        log
        settings
        configurationService
    end

    methods

        function obj = InitializeRigPresenter(configurationService, view)
            if nargin < 2
                view = symphonyui.ui.views.InitializeRigView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.InitializeRigSettings();
            obj.configurationService = configurationService;
        end

    end

    methods (Access = protected)

        function willGo(obj, ~, ~)
            obj.populateDescriptionList();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
            obj.updateStateOfControls();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Initialize', @obj.onViewSelectedInitialize);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function populateDescriptionList(obj)
            classNames = obj.configurationService.getAvailableRigDescriptions();

            displayNames = cell(1, numel(classNames));
            for i = 1:numel(classNames)
                split = strsplit(classNames{i}, '.');
                displayNames{i} = appbox.humanize(split{end});
            end

            if numel(classNames) > 0
                obj.view.setDescriptionList(displayNames, classNames);
            else
                obj.view.setDescriptionList({'(None)'}, {[]});
            end
            obj.view.enableSelectDescription(numel(classNames) > 0);
        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    if obj.view.getEnableInitialize()
                        obj.onViewSelectedInitialize();
                    end
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedInitialize(obj, ~, ~)
            obj.view.update();

            description = obj.view.getSelectedDescription();
            try
                obj.configurationService.initializeRig(description);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                obj.configurationService.initializeRig([]);
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
        
        function updateStateOfControls(obj)
            descriptionList = obj.view.getDescriptionList();
            hasDescription = ~isempty(descriptionList{1});
            
            obj.view.enableInitialize(hasDescription);
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
