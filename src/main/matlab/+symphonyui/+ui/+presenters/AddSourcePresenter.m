classdef AddSourcePresenter < appbox.Presenter

    properties (Access = private)
        log
        settings
        documentationService
        initialParent
    end

    methods

        function obj = AddSourcePresenter(documentationService, initialParent, view)
            if nargin < 2
                initialParent = [];
            end
            if nargin < 3
                view = symphonyui.ui.views.AddSourceView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.AddSourceSettings();
            obj.documentationService = documentationService;
            obj.initialParent = initialParent;
        end

    end

    methods (Access = protected)

        function willGo(obj, ~, ~)
            obj.populateParentList();
            obj.view.setSelectedParent(obj.initialParent);
            obj.populateDescriptionList();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
        end

        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'SelectedParent', @obj.onViewSelectedParent);
            obj.addListener(v, 'Add', @obj.onViewSelectedAdd);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function populateParentList(obj)
            sources = obj.documentationService.getExperiment().allSources();

            names = cell(1, numel(sources));
            for i = 1:numel(sources)
                names{i} = sources{i}.label;
            end
            names = [{'(None)'}, names];
            values = [{[]}, sources];

            obj.view.setParentList(names, values);
            obj.view.enableSelectParent(numel(sources) > 0);
        end

        function populateDescriptionList(obj)
            parent = obj.view.getSelectedParent();
            if isempty(parent)
                parentType = [];
            else
                parentType = parent.getType();
            end
            classNames = obj.documentationService.getAvailableSourceDescriptions(parentType);

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
            obj.view.enableAdd(numel(classNames) > 0);
            obj.view.enableSelectDescription(numel(classNames) > 0);
        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedParent(obj, ~, ~)
            obj.populateDescriptionList();
        end

        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();

            parent = obj.view.getSelectedParent();
            description = obj.view.getSelectedDescription();
            try
                source = obj.documentationService.addSource(parent, description);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save presenter settings: ' x.message], x);
            end

            obj.result = source;
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
