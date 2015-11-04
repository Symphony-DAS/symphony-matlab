classdef BeginEpochGroupPresenter < appbox.Presenter

    properties (Access = private)
        log
        settings
        documentationService
    end

    methods

        function obj = BeginEpochGroupPresenter(documentationService, view)
            if nargin < 2
                view = symphonyui.ui.views.BeginEpochGroupView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.BeginEpochGroupSettings();
            obj.documentationService = documentationService;
        end

    end

    methods (Access = protected)

        function onGoing(obj, ~, ~)
            obj.populateParent();
            obj.populateSourceList();
            obj.populateDescriptionList();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Begin', @obj.onViewSelectedBegin);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function populateParent(obj)
            group = obj.documentationService.getCurrentEpochGroup();
            if isempty(group)
                parent = '(None)';
            else
                parent = group.label;
            end
            obj.view.setParent(parent);
        end

        function populateSourceList(obj)
            sources = obj.documentationService.getExperiment().allSources();

            names = cell(1, numel(sources));
            for i = 1:numel(sources)
                names{i} = sources{i}.label;
            end

            obj.view.setSourceList(names, sources);
        end

        function populateDescriptionList(obj)
            classNames = obj.documentationService.getAvailableEpochGroupDescriptions();

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
            obj.view.enableBegin(numel(classNames) > 0);
            obj.view.enableSelectDescription(numel(classNames) > 0);
        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedBegin();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedBegin(obj, ~, ~)
            obj.view.update();

            source = obj.view.getSelectedSource();
            description = obj.view.getSelectedDescription();
            try
                group = obj.documentationService.beginEpochGroup(source, description);
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

            obj.result = group;
            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
        function loadSettings(obj)
            s = find(cellfun(@(s)strcmp(obj.settings.selectedSourceUuid, s.uuid), obj.view.getSourceList()), 1);
            if ~isempty(s)
                obj.view.setSelectedSource(obj.view.getSourceList{s});
            end
            if any(strcmp(obj.settings.selectedDescription, obj.view.getDescriptionList()))
                obj.view.setSelectedDescription(obj.settings.selectedDescription);
            end
        end

        function saveSettings(obj)
            obj.settings.selectedSourceUuid = obj.view.getSelectedSource().uuid;
            obj.settings.selectedDescription = obj.view.getSelectedDescription();
            obj.settings.save();
        end

    end

end
