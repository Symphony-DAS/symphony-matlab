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
            obj.view.enableExperimentName(false);
            obj.view.enableExperimentLocation(false);
            obj.view.enableExperimentPurpose(false);
            obj.view.enableExperimentStartTime(false);
            obj.view.enableEpochGroupLabel(false);
            obj.view.enableEpochLabel(false);
            
            obj.addExperiment();
            obj.selectExperiment();
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
        
        function addExperiment(obj)
            obj.view.setExperimentNode(obj.experiment.name, obj.experiment.id);
            obj.idMap(obj.experiment.id) = obj.experiment;
            
            groups = obj.experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups(i));
            end
            
            notes = obj.experiment.notes;
            for i = 1:numel(notes)
                obj.addNote(notes(i));
            end
        end
        
        function selectExperiment(obj)
            obj.view.setExperimentName(obj.experiment.name);
            obj.view.setExperimentLocation(obj.experiment.location);
            obj.view.setExperimentStartTime(obj.experiment.startTime);
            obj.view.setExperimentPurpose(obj.experiment.purpose);
            obj.view.setSelectedNode(obj.experiment.id);
            obj.view.setSelectedCard(1);
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.experiment, obj.app);
            presenter.goWaitStop();
        end
        
        function onExperimentBeganEpochGroup(obj, ~, data)
            group = data.epochGroup;
            obj.addEpochGroup(group);
            obj.selectEpochGroup(group);
            obj.view.setEpochGroupNodeCurrent(group.id);
            obj.view.enableEndEpochGroup(true);
        end
        
        function addEpochGroup(obj, group)
            obj.view.addEpochGroupNode(group.parent.id, group.label, group.id);
            obj.idMap(group.id) = group;
            
            groups = group.children;
            for i = 1:numel(groups)
                obj.addEpochGroupNode(groups(i));
            end
        end
        
        function selectEpochGroup(obj, group)
            obj.view.setEpochGroupLabel(group.label);
            obj.view.setSelectedNode(group.id);
            obj.view.setSelectedCard(2);
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
        
        function addEpoch(obj, epoch)
            obj.view.addEpochNode(epoch.epochGroup.id, epoch.label, epoch.id);
            obj.idMap(epoch.id) = epoch;
        end
        
        function selectEpoch(obj, epoch)
            obj.view.setEpochLabel(epoch.label);
            obj.view.setSelectedNode(epoch.id);
            obj.view.setSelectedCard(3);
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
            obj.idMap(note.id) = note;
        end
        
        function onViewSelectedNode(obj, ~, ~)
            id = obj.view.getSelectedNode();
            item = obj.idMap(id);
            switch class(item)
                case 'symphonyui.core.Experiment'
                    obj.selectExperiment();
                case 'symphonyui.core.EpochGroup'
                    obj.selectEpochGroup(item);
                case 'symphonyui.core.Epoch'
                    obj.selectEpoch(item);
            end
        end

    end

end
