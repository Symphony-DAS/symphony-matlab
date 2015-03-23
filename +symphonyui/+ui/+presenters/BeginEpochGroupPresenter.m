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
            if isempty(obj.experiment.currentEpochGroup)
                parent = [obj.experiment.name ' (Experiment)'];
            else
                parent = obj.experiment.currentEpochGroup.label;
            end
            obj.view.setParent(parent);
            
            config = obj.app.config;
            labelList = config.get(symphonyui.app.Settings.epochGroupLabelList);
            try
                obj.view.setLabelList(labelList());
            catch x
                msg = ['Unable to set view from config: ' x.message];
                obj.log.debug(msg, x);
                obj.view.showError(msg);
            end
            
            sourceList = {};
            sources = obj.experiment.getFlatSourceList();
            for i = 1:numel(sources)
                sourceList{end + 1} = sources(i).id; %#ok<AGROW>
            end
            obj.view.setSourceList(sourceList);
            if ~isempty(sourceList)
                obj.view.setSelectedSource(sourceList{end});
            end
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Begin', @obj.onViewSelectedBegin);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end
    
    methods (Access = private)

        function onViewKeyPress(obj, ~, data)
            switch data.key
                case 'return'
                    obj.onViewSelectedBegin();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedBegin(obj, ~, ~)
            obj.view.update();
            
            label = obj.view.getSelectedLabel();
            source = obj.view.getSelectedSource();
            if isempty(source)
                obj.view.showError('Epoch group must have a source');
                return;
            end
            
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

