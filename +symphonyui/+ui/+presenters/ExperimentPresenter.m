classdef ExperimentPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
    end
    
    methods

        function obj = ExperimentPresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.SettingsView([]);
            end
            
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.addListener(view, 'SelectedNode', @obj.onViewSelectedNode);
            
            obj.experiment = experiment;
            obj.addListener(experiment, 'BeganEpochGroup', @obj.onExperimentBeganEpochGroup);
            obj.addListener(experiment, 'EndedEpochGroup', @obj.onExperimentEndedEpochGroup);
            obj.addListener(experiment, 'AddedNote', @obj.onExperimentAddedNote);
            obj.addListener(experiment, 'Closed', @obj.onExperimentClosed);
        end

    end

    methods (Access = protected)

        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.ui.Presenter(obj);
        end

    end

    methods (Access = private)
        
        function onViewSelectedNode(obj, ~, ~)
            disp('View Selected Node');
            obj.view.getSelectedNode()
        end
        
        function onExperimentBeganEpochGroup(obj, ~, ~)
            disp('Experiment Began Epoch Group');
        end
        
        function onExperimentEndedEpochGroup(obj, ~, ~)
            disp('Experiment Ended Epoch Group');
        end
        
        function onExperimentAddedNote(obj, ~, ~)
            disp('Experiment Added Note');
        end
        
        function onExperimentClosed(obj, ~, ~)
            disp('Experiment Closed');
        end

    end

end
