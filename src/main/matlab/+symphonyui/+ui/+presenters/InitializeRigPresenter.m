classdef InitializeRigPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        configurationService
    end
    
    methods
        
        function obj = InitializeRigPresenter(configurationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.InitializeRigView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.view.setWindowStyle('modal');
            
            obj.configurationService = configurationService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj, ~, ~)
            obj.populateDescriptionList();
        end
        
        function onBind(obj)
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
                displayNames{i} = symphonyui.core.util.humanize(split{end});
            end
            
            if numel(classNames) > 0
                obj.view.setDescriptionList(displayNames, classNames);
                obj.view.setSelectedDescription(classNames{end});
            else
                obj.view.setDescriptionList('(None)', '(None)');
            end
            obj.view.enableInitialize(numel(classNames) > 0);
            obj.view.enableSelectDescription(numel(classNames) > 0);
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedInitialize();
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

