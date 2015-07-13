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
            obj.selectExperiments({obj.documentationService.getCurrentExperiment()});
        end
        
        function onStopping(obj)
            obj.unbindEntities();
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
            obj.selectDevices({device});
            obj.updateViewState();
        end
        
        function addDevice(obj, device)
            node = obj.view.addDeviceNode(obj.view.getDevicesFolderNode(), device.name, device);
            obj.uuidToNode(device.uuid) = node;
        end
        
        function selectDevices(obj, devices)
            deviceArray = [devices{:}];
            
            obj.view.setDeviceName(mergeFields({deviceArray.name}));
            obj.view.setDeviceManufacturer(mergeFields({deviceArray.manufacturer}));
            obj.view.setDataCardSelection(obj.view.DEVICE_DATA_CARD);
            
            obj.commonSelect(devices);
        end
        
        function onViewSelectedAddSource(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddSourcePresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceAddedSource(obj, ~, event)
            source = event.data;
            obj.addSource(source);
            obj.selectSources({source});
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
        
        function selectSources(obj, sources)
            sourceArray = [sources{:}];
            
            obj.view.setSourceLabel(mergeFields({sourceArray.label}));
            obj.view.setDataCardSelection(obj.view.SOURCE_DATA_CARD);
            
            obj.commonSelect(sources);
        end
        
        function selectExperiments(obj, experiments)
            experimentArray = [experiments{:}];
            
            obj.view.setExperimentPurpose(mergeFields({experimentArray.purpose}));
            obj.view.setExperimentStartTime(mergeTimes([experimentArray.startTime]));
            obj.view.setExperimentEndTime(mergeTimes([experimentArray.endTime]));
            obj.view.setDataCardSelection(obj.view.EXPERIMENT_DATA_CARD);
            
            obj.commonSelect(experiments);
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceBeganEpochGroup(obj, ~, event)
            group = event.data;
            obj.addEpochGroup(group);
            obj.selectEpochGroups({group});
            obj.view.setEpochGroupNodeCurrent(obj.uuidToNode(group.uuid));
            obj.updateViewState();
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            obj.documentationService.endEpochGroup();
        end
        
        function onServiceEndedEpochGroup(obj, ~, event)
            group = event.data;
            obj.selectEpochGroups({group});
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
        
        function selectEpochGroups(obj, groups)
            groupArray = [groups{:}];
            sourceArray = [groupArray.source];
            
            obj.view.setEpochGroupLabel(mergeFields({groupArray.label}));
            obj.view.setEpochGroupStartTime(mergeTimes([groupArray.startTime]));
            obj.view.setEpochGroupEndTime(mergeTimes([groupArray.endTime]));
            obj.view.setEpochGroupSource(mergeFields({sourceArray.label}));
            obj.view.setDataCardSelection(obj.view.EPOCH_GROUP_DATA_CARD);
            
            obj.commonSelect(groups);
        end
        
        function addEpoch(obj, epoch)
            
        end
        
        function selectEntities(obj, entities)
            obj.view.setDataCardSelection(obj.view.EMPTY_DATA_CARD);
            
            obj.commonSelect(entities);
        end
        
        function onViewSelectedNodes(obj, ~, ~)
            import symphonyui.ui.views.EntityNodeType;
            
            obj.unbindEntities();
            
            nodes = obj.view.getSelectedNodes();
            
            values = [nodes(:).Value];
            entities = {values(:).entity};
            type = unique([values(:).type]);
            
            if any(type == EntityNodeType.NON_ENTITY)
                obj.selectNodes(nodes);
                return;
            end
            
            if numel(type) > 1
                obj.selectEntities(entities);
            else
                switch type
                    case EntityNodeType.DEVICE
                        obj.selectDevices(entities);
                    case EntityNodeType.SOURCE
                        obj.selectSources(entities);
                    case EntityNodeType.EXPERIMENT
                        obj.selectExperiments(entities);
                    case EntityNodeType.EPOCH_GROUP
                        obj.selectEpochGroups(entities);
                    case EntityNodeType.EPOCH_BLOCK
                        obj.selectEpochBlocks(entities);
                    case EntityNodeType.EPOCH
                        obj.selectEpochs(entities);
                    otherwise
                        obj.selectEntities(entities);
                        return;
                end
            end
            
            obj.bindEntities(entities);
        end
        
        function commonSelect(obj, entities)
            obj.populateAttributes(entities);
            obj.enableAttributes(true);
            
            nodes = uiextras.jTree.TreeNode.empty(0, numel(entities));
            for i = 1:numel(entities)
                nodes(i) = obj.uuidToNode(entities{i}.uuid);
            end
            obj.view.setSelectedNodes(nodes);
        end
        
        function bindEntities(obj, entities)
            % Only need to bind to the first entity because they all get properties, keywords, and notes equally.
            entity = entities{1};
            
            l = {};
            l{end + 1} = addlistener(entity, 'AddedProperty', @obj.onEntityAddedProperty);
            l{end + 1} = addlistener(entity, 'RemovedProperty', @obj.onEntityRemovedProperty);
            l{end + 1} = addlistener(entity, 'AddedKeyword', @obj.onEntityAddedKeyword);
            l{end + 1} = addlistener(entity, 'RemovedKeyword', @obj.onEntityRemovedKeyword);
            l{end + 1} = addlistener(entity, 'AddedNote', @obj.onEntityAddedNote);
            obj.entityListeners = l;
        end
        
        function unbindEntities(obj)
            while ~isempty(obj.entityListeners)
                delete(obj.entityListeners{1});
                obj.entityListeners(1) = [];
            end
        end
        
        function enableAttributes(obj, tf)
            obj.view.enableProperties(tf);
            obj.view.enableKeywords(tf);
            obj.view.enableNotes(tf);
        end
        
        function populateAttributes(obj, entities)
            obj.populateProperties(entities);
            obj.populateKeywords(entities);
            obj.populateNotes(entities);
        end
        
        function populateProperties(obj, entities)
            % TODO: merge properties
            entities = entities{1};
            
            keys = entities.propertiesMap.keys;
            values = cell(1, numel(keys));
            for i = 1:numel(keys)
                values{i} = {keys{i}, entities.propertiesMap(keys{i})};
            end
            obj.view.setProperties(values);
        end
        
        function onViewSelectedAddProperty(obj, ~, ~)
            nodes = obj.view.getSelectedNodes();
            values = [nodes(:).Value];
            entities = {values(:).entity};
            
            presenter = symphonyui.ui.presenters.AddPropertyPresenter(entities, obj.app);
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
            nodes = obj.view.getSelectedNodes();
            values = [nodes(:).Value];
            entities = {values(:).entity};
            
            for i = 1:numel(entities)
                entities{i}.removeProperty(key);
            end
        end
        
        function onEntityRemovedProperty(obj, ~, event)
            obj.view.removeProperty(event.data);
        end
        
        function populateKeywords(obj, entities)
            % TODO: merge keywords
            entities = entities{1};
            
            obj.view.setKeywords(entities.keywords);
        end
        
        function onViewSelectedAddKeyword(obj, ~, ~)
            nodes = obj.view.getSelectedNodes();
            values = [nodes(:).Value];
            entities = {values(:).entity};
            
            presenter = symphonyui.ui.presenters.AddKeywordPresenter(entities, obj.app);
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
            nodes = obj.view.getSelectedNodes();
            values = [nodes(:).Value];
            entities = {values(:).entity};
            
            for i = 1:numel(entities)
                entities{i}.removeKeyword(keyword);
            end
        end
        
        function onEntityRemovedKeyword(obj, ~, event)
            obj.view.removeKeyword(event.data);
        end
        
        function populateNotes(obj, entities)
            % TODO: merge notes
            entities = entities{1};
            
            notes = entities.notes;
            values = cell(1, numel(notes));
            for i = 1:numel(notes)
                values{i} = {datestr(notes{i}.time, 14), notes{i}.text};
            end
            obj.view.setNotes(values);
        end
        
        function onViewSelectedAddNote(obj, ~, ~)
            nodes = obj.view.getSelectedNodes();
            values = [nodes(:).Value];
            entities = {values(:).entity};
            
            presenter = symphonyui.ui.presenters.AddNotePresenter(entities, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntityAddedNote(obj, ~, event)
            note = event.data;
            obj.view.addNote(datestr(note.time, 14), note.text);
        end
        
        function selectNodes(obj, nodes)
            obj.view.setDataCardSelection(obj.view.EMPTY_DATA_CARD);
            obj.view.setProperties({});
            obj.view.setKeywords({});
            obj.view.setNotes({});
            obj.enableAttributes(false);
            obj.view.setSelectedNodes(nodes);
        end
        
        function updateViewState(obj)
            obj.view.enableBeginEpochGroup(~isempty(obj.documentationService.getCurrentExperiment().sources));
            obj.view.enableEndEpochGroup(~isempty(obj.documentationService.getCurrentEpochGroup()));
        end
        
    end

end

function f = mergeFields(fields)
    f = strjoin(unique(fields), ', ');
end

function f = mergeTimes(times)
    fields = cell(1, numel(times));
    for i = 1:numel(times)
        fields{i} = strtrim(datestr(times(i), 14));
    end
    f = mergeFields(fields);
end
