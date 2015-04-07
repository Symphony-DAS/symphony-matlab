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
            obj.populateFromConfig();
            obj.populateParent();
            obj.populateSourceList();
            obj.view.setSelectedSource(obj.view.getSourceList{end});
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'Begin', @obj.onViewSelectedBegin);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
            
            e = obj.experiment;
            obj.addListener(e, 'AddedSource', @obj.onExperimentAddedSource);
        end

    end
    
    methods (Access = private)
        
        function populateFromConfig(obj)
            import symphonyui.app.Settings;
            
            config = obj.app.config;
            labelList = config.get(Settings.EPOCH_GROUP_LABEL_LIST);
            try
                obj.view.setLabelList(labelList());
            catch x
                msg = ['Unable to populate view from config: ' x.message];
                obj.log.debug(msg, x);
                obj.view.showError(msg);
            end
        end
        
        function onViewKeyPress(obj, ~, data)
            switch data.key
                case 'return'
                    obj.onViewSelectedBegin();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function populateParent(obj)
            if isempty(obj.experiment.currentEpochGroup)
                parent = [obj.experiment.name ' (Experiment)'];
            else
                parent = obj.experiment.currentEpochGroup.label;
            end
            obj.view.setParent(parent);
        end
        
        function onViewSelectedAddSource(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddSourcePresenter(obj.experiment, obj.app);
            presenter.goWaitStop();
        end
        
        function onExperimentAddedSource(obj, ~, ~)
            obj.populateSourceList();
            obj.view.setSelectedSource(obj.view.getSourceList{end});
        end
        
        function populateSourceList(obj)
            list = obj.experiment.getAllSourceIds();
            obj.view.setSourceList(list);
        end
        
        function onViewSelectedBegin(obj, ~, ~)
            obj.view.update();
            
            label = obj.view.getSelectedLabel();
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

