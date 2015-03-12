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
        
        function setExperiment(obj, experiment)
            obj.experiment = experiment;
            
            obj.view.setExperimentNode(experiment.name, experiment.id);
            groups = experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroupNode(groups(i));
            end
        end

    end

    methods (Access = protected)

        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.ui.Presenter(obj);
            obj.setExperiment(obj.experiment);
            obj.view.setWindowKeyPressFcn(@obj.onViewWindowKeyPress);
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
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.experiment, obj.app);
            presenter.view.setParentView(obj.view);
            presenter.view.showDialog();
        end
        
        function onExperimentBeganEpochGroup(obj, ~, data)
            group = data.epochGroup;
            obj.addEpochGroupNode(group);
            obj.view.expandNode(obj.getEpochGroupParentId(group));
            obj.view.setEpochGroupNodeCurrent(group.id);
            obj.view.enableEndEpochGroup(true);
        end
        
        function addEpochGroupNode(obj, group)
            obj.view.addEpochGroupNode(obj.getEpochGroupParentId(group), group.label, group.id);
            
            groups = group.children;
            for i = 1:numel(groups)
                obj.addEpochGroupNode(groups(i));
            end
        end
        
        function id = getEpochGroupParentId(obj, group)
            if isempty(group.parent)
                id = obj.experiment.id;
            else
                id = group.parent.id;
            end
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            obj.experiment.endEpochGroup();
        end
        
        function onExperimentEndedEpochGroup(obj, ~, data)
            group = data.epochGroup;
            obj.view.collapseNode(group.id);
            obj.view.setEpochGroupNodeNormal(group.id);
            obj.view.enableEndEpochGroup(obj.experiment.hasCurrentEpochGroup());
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
