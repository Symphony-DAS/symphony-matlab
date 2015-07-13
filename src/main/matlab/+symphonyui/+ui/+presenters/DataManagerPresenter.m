classdef DataManagerPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
        entityListeners
        uuidToNode
    end
    
    methods
        
        function obj = DataManagerPresenter(documentationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.DataManagerView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.documentationService = documentationService;
            obj.entityListeners = {};
            obj.uuidToNode = containers.Map();
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateEntityTree();
            obj.updateViewState();
        end
        
        function onGo(obj)
            obj.selectExperiment(obj.documentationService.getCurrentExperiment());
        end
        
        function onStopping(obj)
            obj.unbindEntity();
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
        
        function populateEntityTree(obj)
            experiment = obj.documentationService.getCurrentExperiment();
            
            obj.view.setExperimentNode(experiment.purpose, experiment);
            obj.uuidToNode(experiment.uuid) = obj.view.getExperimentNode();
            
            devices = experiment.devices;
            for i = 1:numel(devices)
                obj.addDevice(devices{i});
            end
            obj.view.expandNode(obj.view.getDevicesFolderNode());
            
            sources = experiment.sources;
            for i = 1:numel(sources)
                obj.addSource(sources{i});
            end
            obj.view.expandNode(obj.view.getSourcesFolderNode());
            
            groups = experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups{i});
            end
            obj.view.expandNode(obj.view.getEpochGroupsFolderNode());
        end
        
        function onServiceAddedDevice(obj, ~, event)
            device = event.data;
            obj.addDevice(device);
            obj.selectDevice(device);
            obj.updateViewState();
        end
        
        function addDevice(obj, device)
            node = obj.view.addDeviceNode(obj.view.getDevicesFolderNode(), device.name, device);
            obj.uuidToNode(device.uuid) = node;
        end
        
        function selectDevice(obj, device)
            obj.view.setDeviceName(device.name);
            obj.view.setDeviceManufacturer(device.manufacturer);
            obj.view.setDataCardSelection(obj.view.DEVICE_DATA_CARD);
            
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
                parent = obj.view.getSourcesFolderNode();
            else
                parent = obj.uuidToNode(source.parent.uuid);
            end
            
            node = obj.view.addSourceNode(parent, source.label, source);
            obj.uuidToNode(source.uuid) = node;
            
            sources = source.sources;
            for i = 1:numel(sources)
                obj.addSource(sources{i});
            end
        end
        
        function selectSource(obj, source)
            obj.view.setSourceLabel(source.label);
            obj.view.setDataCardSelection(obj.view.SOURCE_DATA_CARD);
            
            obj.selectEntity(source);
        end
        
        function selectExperiment(obj, experiment)            
            obj.view.setExperimentPurpose(experiment.purpose);
            obj.view.setExperimentStartTime(experiment.startTime);
            obj.view.setExperimentEndTime(experiment.endTime);
            obj.view.setDataCardSelection(obj.view.EXPERIMENT_DATA_CARD);
            
            obj.selectEntity(experiment);
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
                parent = obj.view.getEpochGroupsFolderNode();
            else
                parent = obj.uuidToNode(group.parent.uuid);
            end
            
            node = obj.view.addEpochGroupNode(parent, [group.label ' (' group.source.label ')'], group);
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
            obj.view.setDataCardSelection(obj.view.EPOCH_GROUP_DATA_CARD);
            
            obj.selectEntity(group);
        end
        
        function addEpoch(obj, epoch)
            
        end
        
        function onViewSelectedNodes(obj, ~, ~)
            import symphonyui.ui.views.EntityNodeType;
            
            nodes = obj.view.getSelectedNodes();
            entity = nodes.Value.entity;
            type = nodes.Value.type;
            switch type
                case EntityNodeType.DEVICE
                    obj.selectDevice(entity);
                case EntityNodeType.SOURCE
                    obj.selectSource(entity);
                case EntityNodeType.EXPERIMENT
                    obj.selectExperiment(entity);
                case EntityNodeType.EPOCH_GROUP
                    obj.selectEpochGroup(entity);
                case EntityNodeType.EPOCH_BLOCK
                    obj.selectEpochBlock(entity);
                case EntityNodeType.EPOCH
                    obj.selectEpoch(entity);
                otherwise
                    obj.selectNodes(nodes);
            end
        end
        
        function selectEntity(obj, entity)
            obj.view.setSelectedNodes(obj.uuidToNode(entity.uuid));
            obj.bindEntity(entity);
            obj.populateEntityAttributes(entity);
            obj.enableEntityAttributes(true);
        end
        
        function bindEntity(obj, entity)
            obj.unbindEntity();
            
            l = {};
            l{end + 1} = addlistener(entity, 'AddedProperty', @obj.onEntityAddedProperty);
            l{end + 1} = addlistener(entity, 'RemovedProperty', @obj.onEntityRemovedProperty);
            l{end + 1} = addlistener(entity, 'AddedKeyword', @obj.onEntityAddedKeyword);
            l{end + 1} = addlistener(entity, 'RemovedKeyword', @obj.onEntityRemovedKeyword);
            l{end + 1} = addlistener(entity, 'AddedNote', @obj.onEntityAddedNote);
            obj.entityListeners = l;
        end
        
        function unbindEntity(obj)
            while ~isempty(obj.entityListeners)
                delete(obj.entityListeners{1});
                obj.entityListeners(1) = [];
            end
        end
        
        function enableEntityAttributes(obj, tf)
            obj.view.enableProperties(tf);
            obj.view.enableKeywords(tf);
            obj.view.enableNotes(tf);
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
            values = obj.view.getProperties();
            index = cellfun(@(c)strcmp(c{1}, p.key), values);
            if any(index)
                values{index}{2} = p.value;
                obj.view.setProperties(values);
            else
                obj.view.addProperty(p.key, p.value);
            end
        end
        
        function onViewSelectedRemoveProperty(obj, ~, ~)
            key = obj.view.getSelectedProperty();
            if isempty(key)
                return;
            end
            node = obj.view.getSelectedNodes();
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
            node = obj.view.getSelectedNodes();
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
        
        function selectNodes(obj, nodes)
            obj.view.setSelectedNodes(nodes);
            obj.unbindEntity();
            obj.view.setDataCardSelection(obj.view.EMPTY_DATA_CARD);
            obj.view.setProperties({});
            obj.view.setKeywords({});
            obj.view.setNotes({});
            obj.enableEntityAttributes(false);
        end
        
        function updateViewState(obj)
            obj.view.enableBeginEpochGroup(~isempty(obj.documentationService.getCurrentExperiment().sources));
            obj.view.enableEndEpochGroup(~isempty(obj.documentationService.getCurrentEpochGroup()));
        end
        
    end

end
