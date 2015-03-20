classdef ExperimentPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
        idMap
    end
    
    methods

        function obj = ExperimentPresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.ExperimentView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.experiment = experiment;
            obj.idMap = containers.Map();
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.view.setExperimentNode(obj.experiment.name, obj.experiment.id);
            
            groups = obj.experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups(i));
            end
            
            notes = obj.experiment.notes;
            for i = 1:numel(notes)
                obj.addNote(notes(i));
            end
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'AddNote', @obj.onViewSelectedAddNote);
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            
            e = obj.experiment;
            obj.addListener(e, 'BeganEpochGroup', @obj.onExperimentBeganEpochGroup);
            obj.addListener(e, 'EndedEpochGroup', @obj.onExperimentEndedEpochGroup);
            obj.addListener(e, 'AddedNote', @obj.onExperimentAddedNote);
        end

    end

    methods (Access = private)
        
        function onViewKeyPress(obj, ~, data)
            if strcmp(data.key, 't') && strcmp(data.modifier, 'control')
                obj.onViewSelectedAddNote();
            end
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.experiment, obj.app);
            presenter.goWaitStop();
        end
        
        function onExperimentBeganEpochGroup(obj, ~, data)
            group = data.epochGroup;
            obj.addEpochGroup(group);
            obj.view.expandNode(group.parent.id);
            obj.view.setEpochGroupNodeCurrent(group.id);
            obj.view.enableEndEpochGroup(true);
        end
        
        function addEpochGroup(obj, group)
            obj.view.addEpochGroupNode(group.parent.id, group.label, group.id);
            
            groups = group.children;
            for i = 1:numel(groups)
                obj.addEpochGroupNode(groups(i));
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
            presenter.goWaitStop();
        end
        
        function onExperimentAddedNote(obj, ~, ~)
            obj.addNote(obj.experiment.notes(end));
        end
        
        function addNote(obj, note)
            obj.view.addNote(note.id, note.date, note.text);
        end
        
        function onViewSelectedNode(obj, ~, ~)
            disp('View Selected Node');
            obj.view.getSelectedNode()
        end

    end

end
