classdef DataManagerPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
        uuidToNode
        entityEventManager
    end
    
    methods

        function obj = DataManagerPresenter(documentationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.DataManagerView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.documentationService = documentationService;
            obj.uuidToNode = containers.Map();
            obj.entityEventManager = symphonyui.ui.util.EventManager();
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateExperimentTree();
            obj.selectExperiment();
            obj.updateViewState();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'SelectedNodes', @obj.onViewSelectedNodes);
            obj.addListener(v, 'AddProperty', @obj.onViewSelectedAddProperty);
            obj.addListener(v, 'RemoveProperty', @obj.onViewSelectedRemoveProperty);
            obj.addListener(v, 'AddKeyword', @obj.onViewSelectedAddKeyword);
            obj.addListener(v, 'RemoveKeyword', @obj.onViewSelectedRemoveKeyword);
            obj.addListener(v, 'AddNote', @obj.onViewSelectedAddNote);
            
            d = obj.documentationService;
            obj.addListener(d, 'AddedDevice', @obj.onServiceAddedDevice);
            obj.addListener(d, 'AddedSource', @obj.onServiceAddedSource);
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);
        end

    end

    methods (Access = private)
        
        function populateExperimentTree(obj)
            experiment = obj.documentationService.getExperiment();
            
            value.entity = experiment;
            value.selectFcn = @()obj.selectExperiment();
            
            obj.view.setExperimentNode(experiment.purpose, value);
            obj.uuidToNode(experiment.uuid) = obj.view.getExperimentNode();
            
            devices = experiment.devices;
            for i = 1:numel(devices)
                obj.addDevice(devices{i});
            end
            obj.view.expandNode(obj.view.getDevicesRootNode());
            
            sources = experiment.sources;
            for i = 1:numel(sources)
                obj.addSource(sources{i});
            end
            obj.view.expandNode(obj.view.getSourcesRootNode());
            
            groups = experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups{i});
            end
            obj.view.expandNode(obj.view.getEpochGroupsRootNode());
        end
        
        function selectExperiment(obj)
            experiment = obj.documentationService.getExperiment();
            
            obj.view.setExperimentPurpose(experiment.purpose);
            obj.view.setExperimentStartTime(experiment.startTime);
            obj.view.setExperimentEndTime(experiment.endTime);
            obj.view.setSelectedDataCard(obj.view.EXPERIMENT_DATA_CARD);
            
            obj.selectEntity(experiment);
        end
        
        function onServiceAddedDevice(obj, ~, event)
            device = event.data;
            obj.addDevice(device);
            obj.selectDevice(device);
            obj.updateViewState();
        end
        
        function addDevice(obj, device)
            value.entity = device;
            value.selectFcn = @()obj.selectDevice(device);
            
            node = obj.view.addDeviceNode(obj.view.getDevicesRootNode(), device.name, value);
            obj.uuidToNode(device.uuid) = node;
        end
        
        function selectDevice(obj, device)
            obj.view.setDeviceName(device.name);
            obj.view.setDeviceManufacturer(device.manufacturer);
            obj.view.setSelectedDataCard(obj.view.DEVICE_DATA_CARD);
            
            obj.selectEntity(device);
        end
        
        function onViewSelectedAddSource(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddSourcePresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceAddedSource(obj, ~, event)
            source = event.data;
            obj.addSource(source);
            obj.selectSource(source);
            obj.updateViewState();
        end
        
        function addSource(obj, source)
            if isempty(source.parent)
                parent = obj.view.getSourcesRootNode();
            else
                parent = obj.uuidToNode(source.parent.uuid);
            end
            
            value.entity = source;
            value.selectFcn = @()obj.selectSource(source);
            
            node = obj.view.addSourceNode(parent, source.label, value);
            obj.uuidToNode(source.uuid) = node;
            
            sources = source.sources;
            for i = 1:numel(sources)
                obj.addSource(sources{i});
            end
        end
        
        function selectSource(obj, source)
            obj.view.setSourceLabel(source.label);
            obj.view.setSelectedDataCard(obj.view.SOURCE_DATA_CARD);
            
            obj.selectEntity(source);
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceBeganEpochGroup(obj, ~, event)
            group = event.data;
            obj.addEpochGroup(group);
            obj.selectEpochGroup(group);
            obj.view.setEpochGroupNodeCurrent(obj.uuidToNode(group.uuid));
            obj.updateViewState();
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            obj.documentationService.endEpochGroup();
        end
        
        function onServiceEndedEpochGroup(obj, ~, event)
            group = event.data;
            obj.selectEpochGroup(group);
            obj.view.collapseNode(obj.uuidToNode(group.uuid));
            obj.view.setEpochGroupNodeNormal(obj.uuidToNode(group.uuid));
            obj.updateViewState();
        end
        
        function addEpochGroup(obj, group)
            if isempty(group.parent)
                parent = obj.view.getEpochGroupsRootNode();
            else
                parent = obj.uuidToNode(group.parent.uuid);
            end
            
            name = [group.label ' (' group.source.label ')'];
            value.entity = group;
            value.selectFcn = @()obj.selectEpochGroup(group);
            node = obj.view.addEpochGroupNode(parent, name, value);
            
            obj.uuidToNode(group.uuid) = node;
            
            groups = group.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups{i});
            end
        end
        
        function selectEpochGroup(obj, group)
            obj.view.setEpochGroupLabel(group.label);
            obj.view.setEpochGroupStartTime(group.startTime);
            obj.view.setEpochGroupEndTime(group.endTime);
            obj.view.setEpochGroupSource(group.source.label);
            obj.view.setSelectedDataCard(obj.view.EPOCH_GROUP_DATA_CARD);
            
            obj.selectEntity(group);
        end
        
        function addEpoch(obj, epoch)
            
        end
        
        function selectEpoch(obj, epoch)
            
        end
        
        function onViewSelectedNodes(obj, ~, ~)            
            nodes = obj.view.getSelectedNodes();
            if isfield(nodes.Value, 'selectFcn')
                nodes.Value.selectFcn();
            else
                obj.view.setSelectedDataCard(obj.view.EMPTY_DATA_CARD);
            end
        end
        
        function selectEntity(obj, entity)
            obj.view.setSelectedNodes(obj.uuidToNode(entity.uuid));
            
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
            obj.populateEntityKeywords(entity);
            obj.populateEntityNotes(entity);
        end
        
        function populateEntityProperties(obj, entity)
            keys = entity.propertiesMap.keys;
            values = cell(1, numel(keys));
            for i = 1:numel(keys)
                values{i} = {keys{i}, entity.propertiesMap(keys{i})};
            end
            obj.view.setProperties(values);
        end
        
        function onViewSelectedAddProperty(obj, ~, ~)
            node = obj.view.getSelectedNodes();
            entity = node.Value.entity;
            
            presenter = symphonyui.ui.presenters.AddPropertyPresenter(entity, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntityAddedProperty(obj, ~, event)
            p = event.data;
            obj.view.addProperty(p.key, p.value);
        end
        
        function onViewSelectedRemoveProperty(obj, ~, ~)
            key = obj.view.getSelectedProperty();
            if isempty(key)
                return;
            end
            node = obj.getSelectedNodess();
            entity = node.Value.entity;
            entity.removeProperty(key);
        end
        
        function onEntityRemovedProperty(obj, ~, event)
            obj.view.removeProperty(event.data);
        end
        
        function populateEntityKeywords(obj, entity)
            obj.view.setKeywords(entity.keywords);
        end
        
        function onViewSelectedAddKeyword(obj, ~, ~)
            node = obj.view.getSelectedNodes();
            entity = node.Value.entity;
            
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
            node = obj.getSelectedNodess();
            entity = node.Value.entity;
            entity.removeKeyword(keyword);
        end
        
        function onEntityRemovedKeyword(obj, ~, event)
            obj.view.removeKeyword(event.data);
        end
        
        function populateEntityNotes(obj, entity)
            notes = entity.notes;
            values = cell(1, numel(notes));
            for i = 1:numel(notes)
                values{i} = {datestr(notes{i}.time, 14), notes{i}.text};
            end
            obj.view.setNotes(values);
        end
        
        function onViewSelectedAddNote(obj, ~, ~)
            node = obj.view.getSelectedNodes();
            entity = node.Value.entity;
            
            presenter = symphonyui.ui.presenters.AddNotePresenter(entity, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntityAddedNote(obj, ~, event)
            note = event.data;
            obj.view.addNote(datestr(note.time, 14), note.text);
        end
        
        function updateViewState(obj)
            obj.view.enableBeginEpochGroup(~isempty(obj.documentationService.getExperiment().sources));
            obj.view.enableEndEpochGroup(~isempty(obj.documentationService.getCurrentEpochGroup()));
        end
        
    end

end
