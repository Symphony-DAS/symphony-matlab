classdef DataManagerPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
        uuidToNode
    end
    
    methods
        
        function obj = DataManagerPresenter(documentationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.DataManagerView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.documentationService = documentationService;
            obj.uuidToNode = containers.Map();
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateEntityTree();            
            obj.updateEnableStateOfControls();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'SelectedNodes', @obj.onViewSelectedNodes);
            obj.addListener(v, 'SetSourceLabel', @obj.onViewSetSourceLabel);
            obj.addListener(v, 'SetExperimentPurpose', @obj.onViewSetExperimentPurpose);
            obj.addListener(v, 'SetEpochGroupLabel', @obj.onViewSetEpochGroupLabel);
            obj.addListener(v, 'AddProperty', @obj.onViewSelectedAddProperty);
            obj.addListener(v, 'RemoveProperty', @obj.onViewSelectedRemoveProperty);
            obj.addListener(v, 'AddKeyword', @obj.onViewSelectedAddKeyword);
            obj.addListener(v, 'RemoveKeyword', @obj.onViewSelectedRemoveKeyword);
            obj.addListener(v, 'AddNote', @obj.onViewSelectedAddNote);
            obj.addListener(v, 'SendToWorkspace', @obj.onViewSelectedSendToWorkspace);
            obj.addListener(v, 'DeleteEntity', @obj.onViewSelectedDeleteEntity);
            obj.addListener(v, 'Refresh', @obj.onViewSelectedRefresh);
            obj.addListener(v, 'OpenAxesInNewWindow', @obj.onViewSelectedOpenAxesInNewWindow);
            
            d = obj.documentationService;
            obj.addListener(d, 'AddedDevice', @obj.onServiceAddedDevice);
            obj.addListener(d, 'AddedSource', @obj.onServiceAddedSource);
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);
            obj.addListener(d, 'BeganEpochBlock', @obj.onServiceBeganEpochBlock);
            obj.addListener(d, 'EndedEpochBlock', @obj.onServiceEndedEpochBlock);
            obj.addListener(d, 'DeletedEntity', @obj.onServiceDeletedEntity);
        end

    end

    methods (Access = private)
        
        function populateEntityTree(obj)
            experiment = obj.documentationService.getExperiment();
            obj.view.setExperimentNode(['Experiment (' datestr(experiment.startTime, 1) ')'], experiment);
            obj.uuidToNode(experiment.uuid) = obj.view.getExperimentNode();
            
            devices = experiment.devices;
            for i = 1:numel(devices)
                obj.addDeviceNode(devices{i});
            end
            obj.view.expandNode(obj.view.getDevicesFolderNode());
            
            sources = experiment.sources;
            for i = 1:numel(sources)
                obj.addSourceNode(sources{i});
            end
            obj.view.expandNode(obj.view.getSourcesFolderNode());
            
            groups = experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroupNode(groups{i});
            end
            obj.view.expandNode(obj.view.getEpochGroupsFolderNode());
            
            obj.view.setSelectedNodes(obj.uuidToNode(experiment.uuid));
            obj.populateDetailsWithExperiments(experiment);
        end
        
        function onServiceAddedDevice(obj, ~, event)
            device = event.data;
            node = obj.addDeviceNode(device);
            
            obj.view.setSelectedNodes(node);
            
            obj.populateDetailsWithDevices(device);
            obj.updateEnableStateOfControls();
        end
        
        function n = addDeviceNode(obj, device)
            n = obj.view.addDeviceNode(obj.view.getDevicesFolderNode(), device.name, device);
            obj.uuidToNode(device.uuid) = n;
        end
        
        function populateDetailsWithDevices(obj, devices)
            if ~iscell(devices)
                devices = {devices};
            end
            deviceArray = [devices{:}];
            
            obj.view.setDeviceName(mergeFields({deviceArray.name}));
            obj.view.setDeviceManufacturer(mergeFields({deviceArray.manufacturer}));
            obj.view.setCardSelection(obj.view.DEVICE_CARD);
            
            obj.populateAnnotations(devices);
        end
        
        function onViewSelectedAddSource(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddSourcePresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceAddedSource(obj, ~, event)
            source = event.data;
            node = obj.addSourceNode(source);
            
            obj.view.setSelectedNodes(node);
            
            obj.populateDetailsWithSources(source);
            obj.updateEnableStateOfControls();
        end
        
        function n = addSourceNode(obj, source)
            if isempty(source.parent)
                parent = obj.view.getSourcesFolderNode();
            else
                parent = obj.uuidToNode(source.parent.uuid);
            end
            
            n = obj.view.addSourceNode(parent, source.label, source);
            obj.uuidToNode(source.uuid) = n;
            
            children = source.sources;
            for i = 1:numel(children)
                obj.addSourceNode(children{i});
            end
        end
        
        function populateDetailsWithSources(obj, sources)
            if ~iscell(sources)
                sources = {sources};
            end
            sourceArray = [sources{:}];
            
            obj.view.enableSourceLabel(numel(sourceArray) == 1);
            obj.view.setSourceLabel(mergeFields({sourceArray.label}));
            obj.view.setCardSelection(obj.view.SOURCE_CARD);
            
            obj.populateAnnotations(sources);
        end
        
        function onViewSetSourceLabel(obj, ~, ~)
            entities = obj.getSelectedEntities();
            assert(numel(entities) == 1, 'Expected a single selected entity');
            
            source = entities{1};
            label = obj.view.getSourceLabel();            
            try
                source.label = label;
            catch x
                obj.view.showError(x.message);
                return;
            end
            
            snode = obj.uuidToNode(source.uuid);
            obj.view.setNodeName(snode, source.label);
            
            groups = source.epochGroups;
            for i = 1:numel(groups)
                g = groups{i};
                gnode = obj.uuidToNode(g.uuid);
                obj.view.setNodeName(gnode, [g.label ' (' g.source.label ')']);
            end
        end
        
        function populateDetailsWithExperiments(obj, experiments)
            if ~iscell(experiments)
                experiments = {experiments};
            end
            experimentArray = [experiments{:}];
            
            obj.view.enableExperimentPurpose(numel(experimentArray) == 1);
            obj.view.setExperimentPurpose(mergeFields({experimentArray.purpose}));
            obj.view.setExperimentStartTime(mergeTimes([experimentArray.startTime]));
            obj.view.setExperimentEndTime(mergeTimes([experimentArray.endTime]));
            obj.view.setCardSelection(obj.view.EXPERIMENT_CARD);
            
            obj.populateAnnotations(experiments);
        end
        
        function onViewSetExperimentPurpose(obj, ~, ~)
            entities = obj.getSelectedEntities();
            assert(numel(entities) == 1, 'Expected a single selected entity');
            
            experiment = entities{1};
            purpose = obj.view.getExperimentPurpose();
            try
                experiment.purpose = purpose;
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceBeganEpochGroup(obj, ~, event)
            group = event.data;
            node = obj.addEpochGroupNode(group);
            
            obj.view.setSelectedNodes(node);
            obj.view.setEpochGroupNodeCurrent(node);
            
            obj.populateDetailsWithEpochGroups(group);
            obj.updateEnableStateOfControls();
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            try
                obj.documentationService.endEpochGroup();
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceEndedEpochGroup(obj, ~, event)
            group = event.data;
            node = obj.uuidToNode(group.uuid);
            
            obj.view.setSelectedNodes(node);
            obj.view.collapseNode(node);
            obj.view.setEpochGroupNodeNormal(node);
            
            obj.populateDetailsWithEpochGroups(group);
            obj.updateEnableStateOfControls();
        end
        
        function n = addEpochGroupNode(obj, group)
            if isempty(group.parent)
                parent = obj.view.getEpochGroupsFolderNode();
            else
                parent = obj.uuidToNode(group.parent.uuid);
            end
            
            n = obj.view.addEpochGroupNode(parent, [group.label ' (' group.source.label ')'], group);
            obj.uuidToNode(group.uuid) = n;
            
            blocks = group.epochBlocks;
            for i = 1:numel(blocks)
                obj.addEpochBlockNode(blocks{i});
            end
            
            children = group.epochGroups;
            for i = 1:numel(children)
                obj.addEpochGroupNode(children{i});
            end
        end
        
        function populateDetailsWithEpochGroups(obj, groups)
            if ~iscell(groups)
                groups = {groups};
            end
            groupArray = [groups{:}];
            sourceArray = [groupArray.source];
            
            obj.view.enableEpochGroupLabel(numel(groupArray) == 1);
            obj.view.setEpochGroupLabel(mergeFields({groupArray.label}));
            obj.view.setEpochGroupStartTime(mergeTimes([groupArray.startTime]));
            obj.view.setEpochGroupEndTime(mergeTimes([groupArray.endTime]));
            obj.view.setEpochGroupSource(mergeFields({sourceArray.label}));
            obj.view.setCardSelection(obj.view.EPOCH_GROUP_CARD);
            
            obj.populateAnnotations(groups);
        end
        
        function onViewSetEpochGroupLabel(obj, ~, ~)
            entities = obj.getSelectedEntities();
            assert(numel(entities) == 1, 'Expected a single selected entity');
            
            group = entities{1};
            label = obj.view.getEpochGroupLabel();
            try
                group.label = label;
            catch x
                obj.view.showError(x.message);
                return;
            end
            
            gnode = obj.uuidToNode(group.uuid);
            obj.view.setNodeName(gnode, group.label);
        end
        
        function onServiceAddedEpochBlock(obj, ~, event)
            block = event.data;
            obj.addEpochBlockNode(block);
        end
        
        function n = addEpochBlockNode(obj, block)
            parent = obj.uuidToNode(block.epochGroup.uuid);
            n = obj.view.addEpochBlockNode(parent, block.protocolId, block);
            obj.uuidToNode(block.uuid) = n;
            
            epochs = block.epochs;
            for i = 1:numel(epochs)
                obj.addEpochNode(epochs{i});
            end
        end
        
        function populateDetailsWithEpochBlocks(obj, blocks)
            if ~iscell(blocks)
                blocks = {blocks};
            end
            blockArray = [blocks{:}];
            
            obj.view.setEpochBlockProtocolId(mergeFields({blockArray.protocolId}));
            obj.view.setEpochBlockStartTime(mergeTimes([blockArray.startTime]));
            obj.view.setEpochBlockEndTime(mergeTimes([blockArray.endTime]));
            obj.view.setCardSelection(obj.view.EPOCH_BLOCK_CARD);
            
            obj.populateAnnotations(blocks);
        end
        
        function onServiceAddedEpoch(obj, ~, event)
            epoch = event.data;
            obj.addEpochNode(epoch);
        end
        
        function n = addEpochNode(obj, epoch)
            parent = obj.uuidToNode(epoch.epochBlock.uuid);
            n = obj.view.addEpochNode(parent, datestr(epoch.startTime, 'HH:MM:SS:FFF'), epoch);
            obj.uuidToNode(epoch.uuid) = n;
        end
        
        function populateDetailsWithEpochs(obj, epochs)
            if ~iscell(epochs)
                epochs = {epochs};
            end
            
            epochSet = symphonyui.app.EpochSet(epochs);
            
            % Plot
            obj.view.clearEpochDataAxes();
            obj.view.setEpochDataAxesLabels('Time (s)', 'Data');
            responseMap = epochSet.responseMap;
            colorOrder = get(groot, 'defaultAxesColorOrder');
            devices = responseMap.keys;
            groups = [];
            for i = 1:numel(devices)
                color = colorOrder(mod(i, size(colorOrder, 1)), :);
                responses = responseMap(devices{i});
                for k = 1:numel(responses)
                    r = responses{k};
                    ydata = r.getData();
                    rate = r.getSampleRate();
                    xdata = (1:numel(ydata))/rate;
                    
                    obj.view.addEpochDataLine(xdata, ydata, color);
                    groups = [groups i]; %#ok<AGROW>
                end
            end
            obj.view.setEpochDataLegend(devices, groups);
            
            % Protocol parameters
%             parameters = epochSet.commonProtocolParameters;
%             keys = parameters.keys;
%             data = cell(1, numel(keys)); 
%             for i = 1:numel(keys)
%                 data{i} = {keys{i}, mergeFields(parameters(keys{i}))};
%             end
%             obj.view.setEpochProtocolParameters(data);
            
            obj.view.setCardSelection(obj.view.EPOCH_CARD);
            
            obj.populateAnnotations(epochs);
        end
        
        function populateDetailsWithEmpty(obj)
            nodes = obj.view.getSelectedNodes();
            
            if numel(nodes) == 1
                text = obj.view.getNodeName(nodes);
            else
                text = [num2str(numel(nodes)) ' nodes selected'];
            end
            obj.view.setEmptyText(text);
            obj.view.setCardSelection(obj.view.EMPTY_CARD);
            
            obj.populateAnnotations({});
        end
        
        function onViewSelectedNodes(obj, ~, ~)
            obj.populateDetails();
        end
        
        function populateDetails(obj)
            import symphonyui.ui.views.EntityNodeType;
            
            [entities, types] = obj.getSelectedEntities();
            
            if isempty(types) || numel(types) > 1
                obj.populateDetailsWithEmpty();
                return;
            end
            
            switch types
                case EntityNodeType.DEVICE
                    obj.populateDetailsWithDevices(entities);
                case EntityNodeType.SOURCE
                    obj.populateDetailsWithSources(entities);
                case EntityNodeType.EXPERIMENT
                    obj.populateDetailsWithExperiments(entities);
                case EntityNodeType.EPOCH_GROUP
                    obj.populateDetailsWithEpochGroups(entities);
                case EntityNodeType.EPOCH_BLOCK
                    obj.populateDetailsWithEpochBlocks(entities);
                case EntityNodeType.EPOCH
                    obj.populateDetailsWithEpochs(entities);
                otherwise
                    obj.populateDetailsWithEmpty();
            end
        end
        
        function populateAnnotations(obj, entities)
            obj.populateProperties(entities);
            obj.populateKeywords(entities);
            obj.populateNotes(entities);
        end
        
        function populateProperties(obj, entities)
%             entitySet = symphonyui.app.EntitySet(entities);
%             props = entitySet.commonPropertyMap;
%             
%             keys = props.keys;
%             data = cell(1, numel(keys)); 
%             for i = 1:numel(keys)
%                 data{i} = {keys{i}, mergeFields(props(keys{i}))};
%             end
%             
%             obj.view.setProperties(data);
        end
        
        function onViewSelectedAddProperty(obj, ~, ~)
            entitySet = symphonyui.app.EntitySet(obj.getSelectedEntities());
            addlistener(entitySet, 'AddedProperty', @obj.onEntitySetAddedProperty);
            
            presenter = symphonyui.ui.presenters.AddPropertyPresenter(entitySet, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntitySetAddedProperty(obj, ~, event)
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
            
            entitySet = symphonyui.app.EntitySet(obj.getSelectedEntities());
            addlistener(entitySet, 'RemovedProperty', @obj.onEntitySetRemovedProperty);
            try
                entitySet.removeProperty(key);
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onEntitySetRemovedProperty(obj, ~, event)
            obj.view.removeProperty(event.data);
        end
        
        function populateKeywords(obj, entities)
            entitySet = symphonyui.app.EntitySet(entities);
            keywords = entitySet.commonKeywords;
            obj.view.setKeywords(keywords);
        end
        
        function onViewSelectedAddKeyword(obj, ~, ~)
            entitySet = symphonyui.app.EntitySet(obj.getSelectedEntities());
            addlistener(entitySet, 'AddedKeyword', @obj.onEntitySetAddedKeyword);
            
            presenter = symphonyui.ui.presenters.AddKeywordPresenter(entitySet, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntitySetAddedKeyword(obj, ~, event)
            obj.view.addKeyword(event.data);
        end
        
        function onViewSelectedRemoveKeyword(obj, ~, ~)
            keyword = obj.view.getSelectedKeyword();
            if isempty(keyword)
                return;
            end
            
            entitySet = symphonyui.app.EntitySet(obj.getSelectedEntities());
            addlistener(entitySet, 'RemovedKeyword', @obj.onEntitySetRemovedKeyword);
            try
                entitySet.removeKeyword(keyword);
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onEntitySetRemovedKeyword(obj, ~, event)
            obj.view.removeKeyword(event.data);
        end
        
        function populateNotes(obj, entities)
            entitySet = symphonyui.app.EntitySet(entities);
            notes = entitySet.commonNotes;
            
            data = cell(1, numel(notes));
            for i = 1:numel(notes)
                data{i} = {datestr(notes{i}.time, 14), notes{i}.text};
            end
            obj.view.setNotes(data);
        end
        
        function onViewSelectedAddNote(obj, ~, ~)
            entitySet = symphonyui.app.EntitySet(obj.getSelectedEntities());
            addlistener(entitySet, 'AddedNote', @obj.onEntitySetAddedNote);
            
            presenter = symphonyui.ui.presenters.AddNotePresenter(entitySet, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntitySetAddedNote(obj, ~, event)
            note = event.data;
            obj.view.addNote(datestr(note.time, 14), note.text);
        end
        
        function onViewSelectedSendToWorkspace(obj, ~, ~)
            entities = obj.getSelectedEntities();
            assert(numel(entities) == 1, 'Expected a single selected entity');
            try
                obj.documentationService.sendToWorkspace(entities{1});
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedDeleteEntity(obj, ~, ~)
            entities = obj.getSelectedEntities();
            assert(numel(entities) == 1, 'Expected a single selected entity');
            try
                obj.documentationService.deleteEntity(entities{1});
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceDeletedEntity(obj, ~, event)
            uuid = event.data;
            node = obj.uuidToNode(uuid);
            
            obj.view.setSelectedNodes(get(node, 'Parent'));
            obj.view.removeNode(node);
            obj.uuidToNode.remove(uuid);
            
            obj.populateDetails();
            obj.updateEnableStateOfControls();
        end
        
        function onViewSelectedRefresh(obj, ~, ~)
            % TODO: Implement
            obj.view.showError('Not implemented yet');
        end
        
        function onViewSelectedOpenAxesInNewWindow(obj, ~, ~)
            obj.view.openEpochDataAxesInNewWindow();
        end
        
        function updateEnableStateOfControls(obj)
            obj.view.enableBeginEpochGroup(obj.documentationService.canBeginEpochGroup());
            obj.view.enableEndEpochGroup(obj.documentationService.canEndEpochGroup());
        end
        
        function [e, t] = getSelectedEntities(obj)
            nodes = obj.view.getSelectedNodes();
            values = [nodes(:).Value];
            if isempty(values)
                e = [];
                t = [];
                return;
            end
            e = {values(:).entity};
            t = unique([values(:).type]);
        end
        
    end

end

function f = mergeFields(fields)
    if isempty(fields)
        f = '';
        return;
    end
    f = strjoin(unique(fields), ', ');
end

function f = mergeTimes(times)
    fields = cell(1, numel(times));
    for i = 1:numel(times)
        fields{i} = strtrim(datestr(times(i), 14));
    end
    f = mergeFields(fields);
end
