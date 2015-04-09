classdef AddSourcePresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
    end
    
    methods
        
        function obj = AddSourcePresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.AddSourceView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.experiment = experiment;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj, ~, ~)
            obj.populateParentList();
            obj.view.setSelectedParent(obj.view.getParentList{end});
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

        function onViewKeyPress(obj, ~, data)
            switch data.key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function populateParentList(obj)
            list = [{'(None)'}, obj.experiment.getAllSourceIds()];
            obj.view.setParentList(list);
        end
        
        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();
            
            parent = obj.view.getSelectedParent();
            label = obj.view.getLabel();
            
            try
                obj.experiment.addSource(label, parent);
            catch x
                obj.log.debug(x.message, x);
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

