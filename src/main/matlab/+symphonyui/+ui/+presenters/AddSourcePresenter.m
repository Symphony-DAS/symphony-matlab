classdef AddSourcePresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        log
        documentationService
    end
    
    methods
        
        function obj = AddSourcePresenter(documentationService, view)
            if nargin < 2
                view = symphonyui.ui.views.AddSourceView();
            end
            obj = obj@symphonyui.ui.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.documentationService = documentationService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj, ~, ~)
            obj.populateParentList();
            obj.populateDescriptionList();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
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
            classNames = obj.documentationService.getAvailableSourceDescriptions();
            
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
            
            obj.result = source;
            
            obj.close();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.close();
        end
        
    end
    
end

