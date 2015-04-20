classdef ExperimentPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
        idToNode
        entityEventManager
    end
    
    methods

        function obj = ExperimentPresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.ExperimentView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.experiment = experiment;
            obj.idToNode = containers.Map();
            obj.entityEventManager = symphonyui.ui.util.EventManager();
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
            obj.addListener(v, 'RemoveProperty', @obj.onViewSelectedRemoveProperty);
            obj.addListener(v, 'AddKeyword', @obj.onViewSelectedAddKeyword);
            obj.addListener(v, 'RemoveKeyword', @obj.onViewSelectedRemoveKeyword);
            obj.addListener(v, 'AddNote', @obj.onViewSelectedAddNote);
            
            e = obj.experiment;
            obj.addListener(e, 'AddedSource', @obj.onExperimentAddedSource);
            obj.addListener(e, 'BeganEpochGroup', @obj.onExperimentBeganEpochGroup);
            obj.addListener(e, 'EndedEpochGroup', @obj.onExperimentEndedEpochGroup);
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
                obj.addSource(sources{i});
            end
            
            groups = obj.experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups{i});
            end
        end
        
        function selectExperiment(obj)
            obj.view.setExperimentName(obj.experiment.name);
            obj.view.setExperimentLocation(obj.experiment.location);
            obj.view.setExperimentStartTime(obj.experiment.startTime);
            obj.view.setExperimentPurpose(obj.experiment.purpose);
            obj.view.setSelectedNode(obj.entityToId(obj.experiment));
            obj.view.setSelectedCard(obj.view.EXPERIMENT_CARD);
            
            obj.selectEntity(obj.experiment);
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
            
            obj.selectEntity(source);
        end
        
        function onExperimentBeganEpochGroup(obj, ~, event)
            group = event.data;
            obj.addEpochGroup(group);
            obj.selectEpochGroup(group);
            obj.view.setEpochGroupNodeCurrent(obj.entityToId(group));
        end
        
        function onExperimentEndedEpochGroup(obj, ~, event)
            group = event.data;
            obj.selectEpochGroup(group);
            obj.view.collapseNode(obj.entityToId(group));
            obj.view.setEpochGroupNodeNormal(obj.entityToId(group));
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
            
            obj.selectEntity(group);
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
        
        function selectEntity(obj, entity)
            obj.removeEntityListeners();
            obj.addEntityListeners(entity);
            obj.populateEntityAttributes(entity);
        end
        
        function removeEntityListeners(obj)
            obj.entityEventManager.removeAllListeners();
        end
        
        function addEntityListeners(obj, entity)
            manager = obj.entityEventManager;
            manager.addListener(entity, 'AddedProperty', @obj.onEntityAddedProperty);
            manager.addListener(entity, 'RemovedProperty', @obj.onEntityRemovedProperty);
            manager.addListener(entity, 'AddedKeyword', @obj.onEntityAddedKeyword);
            manager.addListener(entity, 'RemovedKeyword', @obj.onEntityRemovedKeyword);
            manager.addListener(entity, 'AddedNote', @obj.onEntityAddedNote);
        end
        
        function populateEntityAttributes(obj, entity)
            obj.populateEntityProperties(entity);
            obj.view.setKeywords(entity.keywords);
            obj.view.setNotes(entity.notes);
        end
        
        function populateEntityProperties(obj, entity)
            propertyMap = entity.propertyMap;
            keys = propertyMap.keys;
            values = propertyMap.values;
            properties = uiextras.jide.PropertyGridField.empty(0, numel(keys) + 1);
            for i = 1:numel(keys)
                properties(i) = uiextras.jide.PropertyGridField(keys{i}, values{i}, 'ReadOnly', true);
            end
            obj.view.setProperties(properties);
        end
        
        function onViewSelectedAddProperty(obj, ~, ~)
            node = obj.idToNode(obj.view.getSelectedNode());
            entity = node.entity;
            
            presenter = symphonyui.ui.presenters.AddPropertyPresenter(entity, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntityAddedProperty(obj, ~, event)
            p = event.data;
            property = uiextras.jide.PropertyGridField(p.key, p.value, 'ReadOnly', true);
            obj.view.addProperty(property);
        end
        
        function onViewSelectedRemoveProperty(obj, ~, ~)
            property = obj.view.getSelectedProperty();
            if isempty(property)
                return;
            end
            obj.getSelectedEntity().removeProperty(property);
        end
        
        function onEntityRemovedProperty(obj, ~, event)
            obj.view.removeProperty(event.data.key);
        end
        
        function onViewSelectedAddKeyword(obj, ~, ~)
            node = obj.idToNode(obj.view.getSelectedNode());
            entity = node.entity;
            
            presenter = symphonyui.ui.presenters.AddKeywordPresenter(entity, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntityAddedKeyword(obj, ~, event)
            obj.view.addKeyword(event.data);
        end
        
        function onViewSelectedRemoveKeyword(obj, ~, ~)
            keyword = obj.view.getSelectedKeyword();
            if isempty(keyword)
                return;
            end
            obj.getSelectedEntity().removeKeyword(keyword);            
        end
        
        function onEntityRemovedKeyword(obj, ~, event)
            obj.view.removeKeyword(event.data);
        end
        
        function onViewSelectedAddNote(obj, ~, ~)
            node = obj.idToNode(obj.view.getSelectedNode());
            entity = node.entity;
            
            presenter = symphonyui.ui.presenters.AddNotePresenter(entity, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntityAddedNote(obj, ~, event)
            obj.view.addNote(event.data);
        end
        
        function e = getSelectedEntity(obj)
            node = obj.idToNode(obj.view.getSelectedNode());
            e = node.entity;
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
