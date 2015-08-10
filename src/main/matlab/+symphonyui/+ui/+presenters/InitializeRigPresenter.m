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
            descriptions = obj.configurationService.getAvailableRigDescriptions();
            
            emptyDescription = symphonyui.core.descriptions.RigDescription();
            
            names = cell(1, numel(descriptions));
            for i = 1:numel(descriptions)
                names{i} = descriptions{i}.displayName;
            end
            names = ['(Empty)', names];
            values = [{emptyDescription}, descriptions];
            
            obj.view.setDescriptionList(names, values);
            obj.view.setSelectedDescription(values{end});
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

