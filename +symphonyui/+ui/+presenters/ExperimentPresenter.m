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
            obj.view.setWindowKeyPressFcn(@obj.onViewWindowKeyPress);
            obj.view.setNodeName(obj.view.getRootNodeId(), obj.experiment.name);
            obj.view.setExperimentName(obj.experiment.name);
            obj.view.setExperimentLocation(obj.experiment.location);
        end
        
        function onViewClosing(obj, ~, ~)
            onViewClosing@symphonyui.ui.Presenter(obj);
        end

    end

    methods (Access = private)
        
        function onViewWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 't') && strcmp(data.Modifier, 'control')
                obj.onViewSelectedAddNote();
            end
        end
        
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
            presenter = symphonyui.ui.presenters.AddNotePresenter(obj.experiment, obj.app);
            presenter.view.setParentView(obj.view);
            presenter.view.showDialog();
        end
        
        function onExperimentAddedNote(obj, ~, ~)
            obj.view.addNote(obj.experiment.notes(end));
        end
        
        function onViewSelectedNode(obj, ~, ~)
            disp('View Selected Node');
            obj.view.getSelectedNode()
        end

    end

end
