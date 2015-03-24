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
            obj.populateFromConfig();
            obj.populateParentList();
            obj.view.setSelectedParent(obj.view.getParentList{end});
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Add', @obj.onViewSelectedAdd);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end
    
    methods (Access = private)
        
        function populateFromConfig(obj)
            import symphonyui.app.Settings;
            
            config = obj.app.config;
            labelList = config.get(symphonyui.app.Settings.SOURCE_LABEL_LIST);
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
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function populateParentList(obj)
            sourceList = {[obj.experiment.name ' (Experiment)']};
            sources = obj.experiment.getFlatSourceList();
            for i = 1:numel(sources)
                sourceList{end + 1} = sources(i).id; %#ok<AGROW>
            end
            obj.view.setParentList(sourceList);
        end
        
        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();
            
            parent = obj.view.getSelectedParent();
            label = obj.view.getSelectedLabel();
            
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

