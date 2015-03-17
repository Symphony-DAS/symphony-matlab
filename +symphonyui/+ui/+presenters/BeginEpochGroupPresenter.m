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
            obj.addListener(view, 'Begin', @obj.onViewSelectedBegin);
            obj.addListener(view, 'Cancel', @obj.onViewSelectedCancel);
            
            obj.experiment = experiment;
        end
        
    end
    
    methods (Access = protected)

        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.ui.Presenter(obj);
            
            obj.view.setWindowKeyPressFcn(@obj.onViewWindowKeyPress);
            
            parent = obj.experiment.currentEpochGroup;
            if isempty(parent)
                obj.view.setParent([obj.experiment.name ' (Experiment)']);
            else
                obj.view.setParent(parent.label);
            end
            
            config = obj.app.config;
            labelList = config.get(symphonyui.infra.Settings.EPOCH_GROUP_LABEL_LIST);
            try
                obj.view.setLabelList(labelList());
            catch x
                msg = ['Unable to set view from config: ' x.message];
                obj.log.debug(msg, x);
                obj.view.showError(msg);
            end
        end

    end
    
    methods (Access = private)

        function onViewWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onViewSelectedBegin();
            elseif strcmp(data.Key, 'escape')
                obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedBegin(obj, ~, ~)
            obj.view.update();
            
            label = obj.view.getSelectedLabel();
            
            try
                obj.experiment.beginEpochGroup(label);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.view.close();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.view.close();
        end
        
    end
    
end

