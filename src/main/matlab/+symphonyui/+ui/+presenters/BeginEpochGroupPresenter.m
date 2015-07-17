classdef BeginEpochGroupPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
    end
    
    methods
        
        function obj = BeginEpochGroupPresenter(documentationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.BeginEpochGroupView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.view.setWindowStyle('modal');
            
            obj.documentationService = documentationService;
        end
        
    end
    
    methods (Access = protected)

        function onGoing(obj, ~, ~)
            obj.populateSourceList();
            obj.updateShouldEndCurrentEpochGroupState();
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
        
        function populateSourceList(obj)
            sources = obj.documentationService.getCurrentExperiment().allSources();
            
            names = cell(1, numel(sources));
            for i = 1:numel(sources)
                names{i} = sources{i}.label;
            end
            
            obj.view.setSourceList(names, sources);
            obj.view.setSelectedSource(sources{end});
        end
        
        function updateShouldEndCurrentEpochGroupState(obj)
            obj.view.enableShouldEndCurrentEpochGroup(obj.documentationService.canEndEpochGroup());
            obj.view.setShouldEndCurrentEpochGroup(obj.documentationService.canEndEpochGroup() && true);
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
            shouldEndCurrentEpochGroup = obj.view.getShouldEndCurrentEpochGroup();
            try
                if shouldEndCurrentEpochGroup
                    obj.documentationService.endEpochGroup();
                end
                obj.documentationService.beginEpochGroup(label, source);
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

