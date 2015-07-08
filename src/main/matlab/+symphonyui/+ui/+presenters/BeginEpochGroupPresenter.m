classdef BeginEpochGroupPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        persistor
    end
    
    methods
        
        function obj = BeginEpochGroupPresenter(persistor, app, view)
            if nargin < 3
                view = symphonyui.ui.views.BeginEpochGroupView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.persistor = persistor;
        end
        
    end
    
    methods (Access = protected)

        function onGoing(obj, ~, ~)
            obj.populateParent();
            obj.populateSourceList();
        end
        
        function onGo(obj, ~, ~)
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
        
        function populateParent(obj)
            if isempty(obj.persistor.currentEpochGroup)
                parent = '(None)';
            else
                parent = obj.persistor.currentEpochGroup.label;
            end
            obj.view.setParent(parent);
        end
        
        function populateSourceList(obj)
            sources = obj.persistor.experiment.allSources();
            names = cell(1, numel(sources));
            for i = 1:numel(sources)
                names{i} = sources{i}.label;
            end
            obj.view.setSourceList(names, sources);
            obj.view.setSelectedSource(sources{end});
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.key
                case 'return'
                    obj.onViewSelectedBegin();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedBegin(obj, ~, ~)
            obj.view.update();
            
            label = obj.view.getLabel();
            source = obj.view.getSelectedSource();
            try
                obj.persistor.beginEpochGroup(label, source);
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

