classdef NewEpochGroupPresenter < SymphonyUI.Presenter
    
    properties (SetAccess = private)
        experiment
    end
    
    methods
        
        function obj = NewEpochGroupPresenter(experiment, view)
            if nargin < 2
                view = SymphonyUI.Views.NewEpochGroupView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            
            obj.experiment = experiment;
            
            obj.addListener(view, 'Begin', @obj.onSelectedBegin);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
        end
        
    end
    
    methods (Access = private)
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedBegin();
            elseif strcmp(data.Key, 'escape')
                obj.view.close();
            end
        end
        
        function onAddExternalSolutionComponent(obj, ~, ~)
            c = obj.view.getSelectedAvailableExternalSolutionComponent();
            obj.view.addExternalSolutionComponent(c);
        end
        
        function onRemoveExternalSolutionComponent(obj, ~, ~)
            c = obj.view.getSelectedAddedExternalSolutionComponent();
            obj.view.removeExternalSolutionComponent(c);
        end
        
        function onSelectedBegin(obj, ~, ~)
            label = obj.view.getLabel();
            recording = obj.view.getRecording();
            keywords = obj.view.getKeywords();
            source = obj.view.getSource();
            
            attributes = [];
            
            obj.experiment.beginEpochGroup(label, source, keywords, attributes);
            
            obj.view.result = true;
        end
        
    end
    
end

