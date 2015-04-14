classdef ExperimentPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
        idToNode
    end
    
    methods

        function obj = ExperimentPresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.ExperimentView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.experiment = experiment;
            obj.idToNode = containers.Map();
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateExperimentTree();
            obj.selectExperiment();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            obj.addListener(v, 'AddProperty', @obj.onViewSelectedAddProperty);
            obj.addListener(v, 'AddKeyword', @obj.onViewSelectedAddKeyword);
            obj.addListener(v, 'AddNote', @obj.onViewSelectedAddNote);
            
            e = obj.experiment;
            obj.addListener(e, 'AddedSource', @obj.onExperimentAddedSource);
            obj.addListener(e, 'BeganEpochGroup', @obj.onExperimentBeganEpochGroup);
            obj.addListener(e, 'EndedEpochGroup', @obj.onExperimentEndedEpochGroup);
            obj.addListener(e, 'AddedNote', @obj.onExperimentAddedNote);
        end

    end

    methods (Access = private)
        
        function populateExperimentTree(obj)
            nodeId = char(java.util.UUID.randomUUID);
            obj.view.setExperimentTreeRootNode(obj.experiment.name, nodeId);
            
            node.entity = obj.experiment;
            node.selectFcn = @()obj.selectExperiment();
            obj.idToNode(nodeId) = node;
            
            sources = obj.experiment.sources;
            for i = 1:numel(sources)
                obj.addSource(sources(i));
            end
            
            groups = obj.experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups(i));
            end
        end
        
        function selectExperiment(obj)
            obj.view.setExperimentName(obj.experiment.name);
            obj.view.setExperimentLocation(obj.experiment.location);
            obj.view.setExperimentStartTime(obj.experiment.startTime);
            obj.view.setExperimentPurpose(obj.experiment.purpose);
            obj.view.setSelectedNode(obj.entityToId(obj.experiment));
            obj.view.setSelectedCard(obj.view.EXPERIMENT_CARD);
        end
        
        function onExperimentAddedSource(obj, ~, event)
            source = event.data;
            obj.addSource(source);
            obj.selectSource(source);
        end
        
        function addSource(obj, source)
            if isempty(source.parent)
                parentId = obj.view.SOURCES_NODE_ID;
            else
                parentId = obj.entityToId(source.parent);
            end
            
            nodeId = char(java.util.UUID.randomUUID);
            obj.view.addSourceNode(parentId, source.id, nodeId);
            
            node.entity = source;
            node.selectFcn = @()obj.selectSource(source);
            obj.idToNode(nodeId) = node;
            
            sources = source.children;
            for i = 1:numel(sources)
                obj.addSource(sources(i));
            end
        end
        
        function selectSource(obj, source)
            obj.view.setSourceLabel(source.label);
            obj.view.setSelectedNode(obj.entityToId(source));
            obj.view.setSelectedCard(obj.view.SOURCE_CARD);
        end
        
        function onExperimentBeganEpochGroup(obj, ~, event)
            group = event.data;
            obj.addEpochGroup(group);
            obj.selectEpochGroup(group);
            obj.view.setEpochGroupNodeCurrent(obj.entityToId(group));
        end
        
        function onExperimentEndedEpochGroup(obj, ~, event)
            group = event.epochGroup;
            obj.selectEpochGroup(group);
            obj.view.collapseNode(obj.entityToId(group));
            obj.view.setEpochGroupNodeNormal(obj.entityToId(group));
        end
        
        function onExperimentAddedNote(obj, ~, event)
            
        end
        
        function addEpochGroup(obj, group)
            if isempty(group.parent)
                parentId = obj.view.EPOCH_GROUPS_NODE_ID;
            else
                parentId = obj.entityToId(group.parent);
            end
            
            nodeId = char(java.util.UUID.randomUUID);
            obj.view.addEpochGroupNode(parentId, group.label, nodeId);
            
            node.entity = group;
            node.selectFcn = @()obj.selectEpochGroup(group);
            obj.idToNode(nodeId) = node;
            
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
            obj.view.setSelectedNode(obj.entityToId(group));
            obj.view.setSelectedCard(obj.view.EPOCH_GROUP_CARD);
        end
        
        function addEpoch(obj, epoch)
            
        end
        
        function selectEpoch(obj, epoch)
            obj.view.setSelectedNode(obj.entityToId(epoch));
        end
        
        function onViewSelectedNode(obj, ~, ~)            
            nodeId = obj.view.getSelectedNode();
            if ~obj.idToNode.isKey(nodeId)
                obj.view.setSelectedCard(obj.view.EMPTY_CARD);
                return;
            end
            
            node = obj.idToNode(nodeId);
            node.selectFcn();
        end
        
        function onViewSelectedAddProperty(obj, ~, ~)
            node = obj.idToNode(obj.view.getSelectedNode());
            disp(node.entity);
            disp('Add property');
        end
        
        function onViewSelectedAddKeyword(obj, ~, ~)
            node = obj.idToNode(obj.view.getSelectedNode());
            disp(node.entity);
            disp('Add keyword');
        end
        
        function onViewSelectedAddNote(obj, ~, ~)
            node = obj.idToNode(obj.view.getSelectedNode());
            disp(node.entity);
            disp('Add note');
        end
        
        function i = entityToId(obj, entity)
            % Performance could be improved here.
            nodes = obj.idToNode.values;
            index = cellfun(@(n)isequal(n.entity, entity), nodes);
            ids = obj.idToNode.keys;
            i = ids{index};
        end
        
    end

end
