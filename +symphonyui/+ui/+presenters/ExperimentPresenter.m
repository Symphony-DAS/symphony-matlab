classdef ExperimentPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
    end
    
    methods

        function obj = ExperimentPresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.ExperimentView();
            end
            
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.addListener(view, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(view, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(view, 'AddNote', @obj.onViewSelectedAddNote);
            obj.addListener(view, 'SelectedNode', @obj.onViewSelectedNode);
            
            obj.experiment = experiment;
            obj.addListener(experiment, 'BeganEpochGroup', @obj.onExperimentBeganEpochGroup);
            obj.addListener(experiment, 'EndedEpochGroup', @obj.onExperimentEndedEpochGroup);
            obj.addListener(experiment, 'AddedNote', @obj.onExperimentAddedNote);
        end

    end

    methods (Access = protected)

        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.ui.Presenter(obj);
            
            obj.view.setNodeName(obj.view.getRootNodeId(), obj.experiment.name);
            obj.view.setExperimentName(obj.experiment.name);
            obj.view.setExperimentLocation(obj.experiment.location);
        end
        
        function onViewClosing(obj, ~, ~)
            onViewClosing@symphonyui.ui.Presenter(obj);
        end

    end

    methods (Access = private)
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            disp('View Selected Begin Epoch Group');
        end
        
        function onExperimentBeganEpochGroup(obj, ~, ~)
            disp('Experiment Began Epoch Group');
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            disp('View Selected End Epoch Group');
        end
        
        function onExperimentEndedEpochGroup(obj, ~, ~)
            disp('Experiment Ended Epoch Group');
        end
        
        function onViewSelectedAddNote(obj, ~, ~)
            disp('View Selected Add Note');
        end
        
        function onExperimentAddedNote(obj, ~, ~)
            disp('Experiment Added Note');
        end
        
        function onViewSelectedNode(obj, ~, ~)
            disp('View Selected Node');
            obj.view.getSelectedNode()
        end

    end

end
