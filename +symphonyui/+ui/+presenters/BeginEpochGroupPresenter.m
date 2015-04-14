classdef BeginEpochGroupPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
    end
    
    methods
        
        function obj = BeginEpochGroupPresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.BeginEpochGroupView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.experiment = experiment;
        end
        
    end
    
    methods (Access = protected)

        function onGoing(obj, ~, ~)
            obj.populateParent();
            obj.populateSourceList();
            obj.view.setSelectedSource(obj.view.getSourceList{end});
            obj.view.requestLabelFocus();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Begin', @obj.onViewSelectedBegin);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end
    
    methods (Access = private)
        
        function onViewKeyPress(obj, ~, event)
            switch event.key
                case 'return'
                    obj.onViewSelectedBegin();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function populateParent(obj)
            if isempty(obj.experiment.currentEpochGroup)
                parent = '(None)';
            else
                parent = obj.experiment.currentEpochGroup.label;
            end
            obj.view.setParent(parent);
        end
        
        function populateSourceList(obj)
            list = obj.experiment.getAllSourceIds();
            obj.view.setSourceList(list);
        end
        
        function onViewSelectedBegin(obj, ~, ~)
            obj.view.update();
            
            label = obj.view.getLabel();
            source = obj.view.getSelectedSource();
            
            try
                obj.experiment.beginEpochGroup(label, source);
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

