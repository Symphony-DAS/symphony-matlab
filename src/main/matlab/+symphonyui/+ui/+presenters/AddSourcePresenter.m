classdef AddSourcePresenter < appbox.Presenter

    properties (Access = private)
        log
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
            obj.documentationService = documentationService;
            obj.initialParent = initialParent;
        end

    end

    methods (Access = protected)

        function willGo(obj, ~, ~)
            obj.populateParentList();
            obj.populateDescriptionList();
            obj.selectParent(obj.initialParent);
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
            sources = obj.documentationService.getExperiment().getAllSources();

            names = cell(1, numel(sources));
            for i = 1:numel(sources)
                names{i} = sources{i}.label;
            end
            names = [{'(None)'}, names];
            values = [{[]}, sources];

            obj.view.setParentList(names, values);
            obj.view.enableSelectParent(numel(sources) > 0);
        end

        function selectParent(obj, parent)
            obj.view.setSelectedParent(parent);
            obj.populateDescriptionList();
            obj.updateStateOfControls();
        end

        function populateDescriptionList(obj)
            parent = obj.view.getSelectedParent();
            if isempty(parent)
                parentType = [];
            else
                parentType = parent.getDescriptionType();
            end
            classNames = obj.documentationService.getAvailableSourceDescriptions(parentType);
            displayNames = appbox.class2display(classNames);

            [displayNames, i] = sort(displayNames);
            classNames = classNames(i);

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
                    if obj.view.getEnableAdd()
                        obj.onViewSelectedAdd();
                    end
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedParent(obj, ~, ~)
            obj.selectParent(obj.view.getSelectedParent());
        end

        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();

            parent = obj.view.getSelectedParent();
            description = obj.view.getSelectedDescription();
            try
                obj.enableControls(false);
                obj.view.startSpinner();
                obj.view.update();
                
                source = obj.documentationService.addSource(parent, description);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                obj.view.stopSpinner();
                obj.enableControls(true);
                return;
            end

            obj.result = source;
            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
        function enableControls(obj, tf)
            obj.view.enableSelectParent(tf);
            obj.view.enableSelectDescription(tf);
            obj.view.enableAdd(tf);
            obj.view.enableCancel(tf);
        end

        function updateStateOfControls(obj)
            descriptionList = obj.view.getDescriptionList();
            hasDescription = ~isempty(descriptionList{1});

            obj.view.enableAdd(hasDescription);
        end

    end

end
