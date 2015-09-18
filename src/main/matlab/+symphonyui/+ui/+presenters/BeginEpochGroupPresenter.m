classdef BeginEpochGroupPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        log
        documentationService
    end
    
    methods
        
        function obj = BeginEpochGroupPresenter(documentationService, view)
            if nargin < 2
                view = symphonyui.ui.views.BeginEpochGroupView();
            end
            obj = obj@symphonyui.ui.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.documentationService = documentationService;
        end
        
    end
    
    methods (Access = protected)

        function onGoing(obj, ~, ~)
            obj.populateParent();
            obj.populateSourceList();
            obj.populateDescriptionList();
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
            
            obj.result = group;
            
            obj.close();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.close();
        end
        
    end
    
end

