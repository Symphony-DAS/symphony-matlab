classdef ExperimentPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
    end
    
    properties (Constant, Access = private)
        EXPERIMENT_ID_PREFIX    = 'X'
        SOURCE_ID_PREFIX        = 'S'
        EPOCH_GROUP_ID_PREFIX   = 'G'
        EPOCH_ID_PREFIX         = 'E'
    end
    
    methods

        function obj = ExperimentPresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.ExperimentView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.experiment = experiment;
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateExperimentTree();
            obj.selectExperiment(obj.experiment);
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            
            e = obj.experiment;
            obj.addListener(e, 'AddedSource', @obj.onExperimentAddedSource);
            obj.addListener(e, 'BeganEpochGroup', @obj.onExperimentBeganEpochGroup);
            obj.addListener(e, 'EndedEpochGroup', @obj.onExperimentEndedEpochGroup);
        end

    end

    methods (Access = private)
        
        function populateExperimentTree(obj)
            obj.view.setExperimentTreeRootNode(obj.experiment.name, obj.getNodeId(obj.experiment));
            
            sources = obj.experiment.sources;
            for i = 1:numel(sources)
                obj.addSource(sources(i));
            end
            
            groups = obj.experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups(i));
            end
        end
        
        function selectExperiment(obj, experiment)
            obj.view.setExperimentName(experiment.name);
            obj.view.setExperimentLocation(experiment.location);
            obj.view.setExperimentStartTime(experiment.startTime);
            obj.view.setExperimentPurpose(experiment.purpose);
            obj.view.setSelectedNode(obj.getNodeId(experiment));
            obj.view.setSelectedCard(obj.view.EXPERIMENT_CARD);
        end
        
        function onExperimentAddedSource(obj, ~, data)
            source = data.source;
            obj.addSource(source);
            obj.selectSource(source);
        end
        
        function addSource(obj, source)
            if isempty(source.parent)
                parentId = obj.view.SOURCES_NODE_ID;
            else
                parentId = obj.getNodeId(source.parent);
            end
            
            obj.view.addSourceNode(parentId, source.id, obj.getNodeId(source));
            
            sources = source.children;
            for i = 1:numel(sources)
                obj.addSource(sources(i));
            end
        end
        
        function selectSource(obj, source)
            obj.view.setSourceLabel(source.label);
            obj.view.setSelectedNode(obj.getNodeId(source));
            obj.view.setSelectedCard(obj.view.SOURCE_CARD);
        end
        
        function onExperimentBeganEpochGroup(obj, ~, data)
            group = data.epochGroup;
            obj.addEpochGroup(group);
            obj.selectEpochGroup(group);
            obj.view.setEpochGroupNodeCurrent(obj.getNodeId(group));
        end
        
        function onExperimentEndedEpochGroup(obj, ~, data)
            group = data.epochGroup;
            obj.selectEpochGroup(group);
            obj.view.collapseNode(obj.getNodeId(group));
            obj.view.setEpochGroupNodeNormal(obj.getNodeId(group));
        end
        
        function addEpochGroup(obj, group)
            if isempty(group.parent)
                parentId = obj.view.EPOCH_GROUPS_NODE_ID;
            else
                parentId = obj.getNodeId(group.parent);
            end
            
            obj.view.addEpochGroupNode(parentId, group.label, obj.getNodeId(group));
            
            groups = group.children;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups(i));
            end
        end
        
        function selectEpochGroup(obj, group)
            obj.view.setEpochGroupLabel(group.label);
            obj.view.setEpochGroupStartTime(group.startTime);
            obj.view.setEpochGroupEndTime(group.endTime);
            obj.view.setEpochGroupSource(group.source.id);
            obj.view.setSelectedNode(obj.getNodeId(group));
            obj.view.setSelectedCard(obj.view.EPOCH_GROUP_CARD);
        end
        
        function addEpoch(obj, epoch)
            
        end
        
        function selectEpoch(obj, epoch)
            obj.view.setSelectedNode(obj.getNodeId(epoch));
        end
        
        function onViewSelectedNode(obj, ~, ~)
            nodeId = obj.view.getSelectedNode();
            if isequal(nodeId, obj.view.SOURCES_NODE_ID) || isequal(nodeId, obj.view.EPOCH_GROUPS_NODE_ID)
                obj.view.setSelectedCard(obj.view.EMPTY_CARD);
                return;
            end
            
            prefix = nodeId(1);
            id = nodeId(2:end);
            switch prefix
                case obj.EXPERIMENT_ID_PREFIX
                    obj.selectExperiment(obj.experiment);
                case obj.SOURCE_ID_PREFIX
                    source = obj.experiment.getSource(id);
                    obj.selectSource(source);
                case obj.EPOCH_GROUP_ID_PREFIX
                    group = obj.experiment.getEpochGroup(id);
                    obj.selectEpochGroup(group);
                case obj.EPOCH_ID_PREFIX
                    epoch = obj.experiment.getEpoch(id);
                    obj.selectEpoch(epoch);
            end
        end
        
        function i = getNodeId(obj, entity)
            switch class(entity)
                case 'symphonyui.core.Experiment'
                    prefix = obj.EXPERIMENT_ID_PREFIX;
                case 'symphonyui.core.Source'
                    prefix = obj.SOURCE_ID_PREFIX;
                case 'symphonyui.core.EpochGroup'
                    prefix = obj.EPOCH_GROUP_ID_PREFIX;
                case 'symphonyui.core.Epoch'
                    prefix = obj.EPOCH_ID_PREFIX;
            end
            i = [prefix, entity.id];
        end

    end

end
