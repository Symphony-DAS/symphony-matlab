classdef AddSourcePresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
    end
    
    methods
        
        function obj = AddSourcePresenter(documentationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.AddSourceView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.documentationService = documentationService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj, ~, ~)
            obj.populateParentList();
        end
        
        function onGo(obj, ~, ~)
            obj.view.requestLabelFocus();
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
            obj.view.setSelectedParent(values{end});
            
            if numel(names) <= 1
                obj.view.enableSelectParent(false);
            end
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();
            
            parent = obj.view.getSelectedParent();
            label = obj.view.getLabel();
            try
                obj.documentationService.addSource(label, parent);
            catch x
                obj.view.showError(x.message);
                return;
            end
            
            obj.view.hide();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.view.hide();
        end
        
    end
    
end

