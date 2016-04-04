classdef DataManagerPresenter < appbox.Presenter

    properties
        viewSelectedCloseFcn
    end

    properties (Access = private)
        log
        settings
        documentationService
        acquisitionService
        configurationService
        uuidToNode
        detailedEntitySet
    end

    methods

        function obj = DataManagerPresenter(documentationService, acquisitionService, configurationService, view)
            if nargin < 4
                view = symphonyui.ui.views.DataManagerView();
            end
            obj = obj@appbox.Presenter(view);

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.DataManagerSettings();
            obj.documentationService = documentationService;
            obj.acquisitionService = acquisitionService;
            obj.configurationService = configurationService;
            obj.detailedEntitySet = symphonyui.core.persistent.collections.EntitySet();
            obj.uuidToNode = containers.Map();
        end

    end

    methods (Access = protected)

        function willGo(obj)
            obj.populateEntityTree();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
            obj.updateStateOfControls();
        end

        function willStop(obj)
            obj.viewSelectedCloseFcn = [];
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save presenter settings: ' x.message], x);
            end
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'SelectedNodes', @obj.onViewSelectedNodes);
            obj.addListener(v, 'ConfigureDevices', @obj.onViewSelectedConfigureDevices);
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'SetSourceLabel', @obj.onViewSetSourceLabel);
            obj.addListener(v, 'SetExperimentPurpose', @obj.onViewSetExperimentPurpose);
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'SetEpochGroupLabel', @obj.onViewSetEpochGroupLabel);
            obj.addListener(v, 'SelectedEpochSignal', @obj.onViewSelectedEpochSignal);
            obj.addListener(v, 'SetProperty', @obj.onViewSetProperty);
            obj.addListener(v, 'AddProperty', @obj.onViewSelectedAddProperty);
            obj.addListener(v, 'RemoveProperty', @obj.onViewSelectedRemoveProperty);
            obj.addListener(v, 'ShowHidePropertyDescription', @obj.onViewSelectedShowHidePropertyDescription);
            obj.addListener(v, 'AddKeyword', @obj.onViewSelectedAddKeyword);
            obj.addListener(v, 'RemoveKeyword', @obj.onViewSelectedRemoveKeyword);
            obj.addListener(v, 'AddNote', @obj.onViewSelectedAddNote);
            obj.addListener(v, 'SelectedPreset', @obj.onViewSelectedPreset);
            obj.addListener(v, 'AddPreset', @obj.onViewSelectedAddPreset);
            obj.addListener(v, 'ManagePresets', @obj.onViewSelectedManagePresets);
            obj.addListener(v, 'SendEntityToWorkspace', @obj.onViewSelectedSendEntityToWorkspace);
            obj.addListener(v, 'DeleteEntity', @obj.onViewSelectedDeleteEntity);
            obj.addListener(v, 'OpenAxesInNewWindow', @obj.onViewSelectedOpenAxesInNewWindow);

            d = obj.documentationService;
            obj.addListener(d, 'AddedSource', @obj.onServiceAddedSource);
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);
            obj.addListener(d, 'DeletedEntity', @obj.onServiceDeletedEntity);

            a = obj.acquisitionService;
            obj.addListener(a, 'ChangedControllerState', @obj.onServiceChangedControllerState);
        end

        function onViewSelectedClose(obj, ~, ~)
            if ~isempty(obj.viewSelectedCloseFcn)
                obj.viewSelectedCloseFcn();
            end
        end

    end

    methods (Access = private)

        function populateEntityTree(obj)
            experiment = obj.documentationService.getExperiment();
            if isempty(experiment.purpose)
                name = datestr(experiment.startTime, 1);
            else
                name = [experiment.purpose ' [' datestr(experiment.startTime, 1) ']'];
            end
            obj.view.setExperimentNode(name, experiment);
            obj.uuidToNode(experiment.uuid) = obj.view.getExperimentNode();

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
            obj.populateDetailsForExperiments(experiment);
        end
        
        function onViewSelectedConfigureDevices(obj, ~, ~)
            presenter = symphonyui.ui.presenters.DevicesPresenter(obj.configurationService);
            presenter.goWaitStop();
        end

        function onViewSelectedAddSource(obj, ~, ~)
            selectedParent = [];
            nodes = obj.view.getSelectedNodes();
            if numel(nodes) == 1 && obj.view.getNodeType(nodes(1)) == symphonyui.ui.views.EntityNodeType.SOURCE
                selectedParent = obj.view.getNodeEntity(nodes(1));
            end

            presenter = symphonyui.ui.presenters.AddSourcePresenter(obj.documentationService, selectedParent);
            presenter.goWaitStop();
        end

        function onServiceAddedSource(obj, ~, event)
            source = event.data;
            node = obj.addSourceNode(source);

            obj.view.stopEditingProperties();
            obj.view.update();
            obj.view.setSelectedNodes(node);
            
            obj.populateDetailsForSources(source);
            obj.updateStateOfControls();
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

        function populateDetailsForSources(obj, sources)
            sourceSet = symphonyui.core.persistent.collections.SourceSet(sources);

            obj.view.enableSourceLabel(sourceSet.size == 1);
            obj.view.setSourceLabel(sourceSet.label);
            obj.view.setCardSelection(obj.view.SOURCE_CARD);

            obj.populateCommonDetailsForEntitySet(sourceSet);
        end

        function onViewSetSourceLabel(obj, ~, ~)
            sourceSet = obj.detailedEntitySet;

            try
                sourceSet.label = obj.view.getSourceLabel();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            for i = 1:sourceSet.size
                source = sourceSet.get(i);

                snode = obj.uuidToNode(source.uuid);
                obj.view.setNodeName(snode, source.label);

                groups = source.epochGroups;
                for k = 1:numel(groups)
                    g = groups{k};
                    gnode = obj.uuidToNode(g.uuid);
                    obj.view.setNodeName(gnode, [g.label ' (' g.source.label ')']);
                end
            end
        end

        function populateDetailsForExperiments(obj, experiments)
            experimentSet = symphonyui.core.persistent.collections.ExperimentSet(experiments);

            obj.view.enableExperimentPurpose(experimentSet.size == 1);
            obj.view.setExperimentPurpose(experimentSet.purpose);
            obj.view.setExperimentStartTime(strtrim(datestr(experimentSet.startTime, 14)));
            obj.view.setExperimentEndTime(strtrim(datestr(experimentSet.endTime, 14)));
            obj.view.setCardSelection(obj.view.EXPERIMENT_CARD);

            obj.populateCommonDetailsForEntitySet(experimentSet);
        end

        function onViewSetExperimentPurpose(obj, ~, ~)
            experimentSet = obj.detailedEntitySet;

            purpose = obj.view.getExperimentPurpose();
            try
                experimentSet.purpose = purpose;
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            for i = 1:experimentSet.size
                experiment = experimentSet.get(i);

                enode = obj.uuidToNode(experiment.uuid);
                if isempty(experiment.purpose)
                    name = datestr(experiment.startTime, 1);
                else
                    name = [experiment.purpose ' [' datestr(experiment.startTime, 1) ']'];
                end
                obj.view.setNodeName(enode, name);
            end
        end

        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            currentGroup = obj.documentationService.getCurrentEpochGroup();
            initialParent = currentGroup;

            initialSource = [];
            if ~isempty(currentGroup)
                initialSource = currentGroup.source;
            end

            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.documentationService, initialParent, initialSource);
            presenter.goWaitStop();
        end

        function onServiceBeganEpochGroup(obj, ~, event)
            group = event.data;
            node = obj.addEpochGroupNode(group);

            obj.view.stopEditingProperties();
            obj.view.update();
            obj.view.setSelectedNodes(node);
            obj.view.setEpochGroupNodeCurrent(node);
            
            obj.populateDetailsForEpochGroups(group);
            obj.updateStateOfControls();
        end

        function onViewSelectedEndEpochGroup(obj, ~, ~)
            try
                obj.documentationService.endEpochGroup();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onServiceEndedEpochGroup(obj, ~, event)
            group = event.data;
            node = obj.uuidToNode(group.uuid);

            obj.view.stopEditingProperties();
            obj.view.update();
            obj.view.setSelectedNodes(node);
            obj.view.collapseNode(node);
            obj.view.setEpochGroupNodeNormal(node);
            
            obj.populateDetailsForEpochGroups(group);
            obj.updateStateOfControls();
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

        function updateEpochGroupNode(obj, group)
            blocks = group.epochBlocks;
            for i = 1:numel(blocks)
                b = blocks{i};
                if ~obj.uuidToNode.isKey(b.uuid)
                    obj.addEpochBlockNode(b);
                else
                    obj.updateEpochBlockNode(b);
                end
            end

            children = group.epochGroups;
            for i = 1:numel(children)
                c = children{i};
                if ~obj.uuidToNode.isKey(c.uuid)
                    obj.addEpochGroupNode(c);
                else
                    obj.updateEpochGroupNode(c);
                end
            end
        end

        function populateDetailsForEpochGroups(obj, groups)
            groupSet = symphonyui.core.persistent.collections.EpochGroupSet(groups);
            sourceSet = symphonyui.core.persistent.collections.SourceSet(groupSet.source);

            obj.view.enableEpochGroupLabel(groupSet.size == 1);
            obj.view.setEpochGroupLabel(groupSet.label);
            obj.view.setEpochGroupStartTime(strtrim(datestr(groupSet.startTime, 14)));
            obj.view.setEpochGroupEndTime(strtrim(datestr(groupSet.endTime, 14)));
            obj.view.setEpochGroupSource(sourceSet.label);
            obj.view.setCardSelection(obj.view.EPOCH_GROUP_CARD);

            obj.populateCommonDetailsForEntitySet(groupSet);
        end

        function onViewSetEpochGroupLabel(obj, ~, ~)
            groupSet = obj.detailedEntitySet;

            label = obj.view.getEpochGroupLabel();
            try
                groupSet.label = label;
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            for i = 1:groupSet.size
                group = groupSet.get(i);

                gnode = obj.uuidToNode(group.uuid);
                obj.view.setNodeName(gnode, [group.label ' (' group.source.label ')']);
            end
        end

        function n = addEpochBlockNode(obj, block)
            parent = obj.uuidToNode(block.epochGroup.uuid);
            split = strsplit(block.protocolId, '.');
            n = obj.view.addEpochBlockNode(parent, [appbox.humanize(split{end}) ' [' datestr(block.startTime, 13) ']'], block);
            obj.uuidToNode(block.uuid) = n;

            epochs = block.epochs;
            for i = 1:numel(epochs)
                obj.addEpochNode(epochs{i});
            end
        end

        function updateEpochBlockNode(obj, block)
            epochs = block.epochs;
            for i = 1:numel(epochs)
                e = epochs{i};
                if ~obj.uuidToNode.isKey(e.uuid)
                    obj.addEpochNode(e);
                end
            end
        end

        function populateDetailsForEpochBlocks(obj, blocks)
            blockSet = symphonyui.core.persistent.collections.EpochBlockSet(blocks);

            obj.view.setEpochBlockProtocolId(blockSet.protocolId);
            obj.view.setEpochBlockStartTime(strtrim(datestr(blockSet.startTime, 14)));
            obj.view.setEpochBlockEndTime(strtrim(datestr(blockSet.endTime, 14)));

            % Protocol parameters
            map = map2pmap(blockSet.protocolParameters);
            try
                properties = uiextras.jide.PropertyGridField.GenerateFrom(map);
            catch x
                properties = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.setEpochBlockProtocolParameters(properties);

            obj.view.setCardSelection(obj.view.EPOCH_BLOCK_CARD);

            obj.populateCommonDetailsForEntitySet(blockSet);
        end

        function n = addEpochNode(obj, epoch)
            parent = obj.uuidToNode(epoch.epochBlock.uuid);
            n = obj.view.addEpochNode(parent, datestr(epoch.startTime, 'HH:MM:SS:FFF'), epoch);
            obj.uuidToNode(epoch.uuid) = n;
        end

        function populateDetailsForEpochs(obj, epochs)
            epochSet = symphonyui.core.persistent.collections.EpochSet(epochs);

            responseMap = epochSet.getResponseMap();
            stimulusMap = epochSet.getStimulusMap();

            names = [strcat(responseMap.keys, ' response'), strcat(stimulusMap.keys, ' stimulus')];
            values = [responseMap.values, stimulusMap.values];
            if isempty(names)
                names = {'(None)'};
                values = {[]};
            end
            obj.view.setEpochSignalList(names, values);

            obj.populateDetailsForSignals(obj.view.getSelectedEpochSignal());

            % Protocol parameters
            map = map2pmap(epochSet.protocolParameters);
            try
                fields = uiextras.jide.PropertyGridField.GenerateFrom(map);
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.setEpochProtocolParameters(fields);

            obj.view.setCardSelection(obj.view.EPOCH_CARD);

            obj.populateCommonDetailsForEntitySet(epochSet);
        end

        function onViewSelectedEpochSignal(obj, ~, ~)
            obj.populateDetailsForSignals(obj.view.getSelectedEpochSignal());
        end

        function populateDetailsForSignals(obj, signals)
            obj.view.clearEpochDataAxes();

            ylabels = cell(1, numel(signals));
            llabels = cell(1, numel(signals));
            colorOrder = get(groot, 'defaultAxesColorOrder');
            for i = 1:numel(signals)
                s = signals{i};
                [ydata, yunits] = s.getData();
                rate = s.getSampleRate();
                xdata = (1:numel(ydata))/rate;
                color = colorOrder(mod(i - 1, size(colorOrder, 1)) + 1, :);
                ylabels{i} = [s.device.name ' (' yunits ')'];
                llabels{i} = datestr(s.epoch.startTime, 'HH:MM:SS:FFF');
                obj.view.addEpochDataLine(xdata, ydata, color);
            end

            obj.view.setEpochDataAxesLabels('Time (s)', strjoin(unique(ylabels), ', '));

            if numel(llabels) > 1
                obj.view.addEpochDataLegend(llabels);
            end
        end

        function populateDetailsForEmpty(obj, text)
            emptySet = symphonyui.core.persistent.collections.EntitySet();

            obj.view.setEmptyText(text);
            obj.view.setCardSelection(obj.view.EMPTY_CARD);

            obj.populateCommonDetailsForEntitySet(emptySet);
        end

        function onViewSelectedNodes(obj, ~, ~)
            obj.view.stopEditingProperties();
            obj.view.update();
            
            obj.populateDetailsForNodes(obj.view.getSelectedNodes());
        end

        function populateDetailsForNodes(obj, nodes)
            import symphonyui.ui.views.EntityNodeType;

            entities = cell(1, numel(nodes));
            types = symphonyui.ui.views.EntityNodeType.empty(0, numel(nodes));
            for i = 1:numel(nodes)
                entities{i} = obj.view.getNodeEntity(nodes(i));
                types(i) = obj.view.getNodeType(nodes(i));
            end

            types = unique(types);
            if numel(types) ~= 1
                obj.populateDetailsForEmpty(strjoin(arrayfun(@(t)char(t), types, 'UniformOutput', false), ', '));
                return;
            end
            type = types(1);

            switch type
                case EntityNodeType.SOURCE
                    obj.populateDetailsForSources(entities);
                case EntityNodeType.EXPERIMENT
                    obj.populateDetailsForExperiments(entities);
                case EntityNodeType.EPOCH_GROUP
                    obj.populateDetailsForEpochGroups(entities);
                case EntityNodeType.EPOCH_BLOCK
                    obj.populateDetailsForEpochBlocks(entities);
                case EntityNodeType.EPOCH
                    obj.populateDetailsForEpochs(entities);
                otherwise
                    obj.populateDetailsForEmpty(strjoin(arrayfun(@(t)char(t), type, 'UniformOutput', false), ', '));
            end
        end

        function populateCommonDetailsForEntitySet(obj, entitySet)
            obj.populatePropertiesForEntitySet(entitySet);
            obj.populateKeywordsForEntitySet(entitySet);
            obj.populateNotesForEntitySet(entitySet);
            obj.populatePresetsForEntitySet(entitySet);
            obj.detailedEntitySet = entitySet;
        end

        function populatePropertiesForEntitySet(obj, entitySet)
            try
                fields = symphonyui.ui.util.desc2field(entitySet.getPropertyDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.setProperties(fields);
        end

        function updatePropertiesForEntitySet(obj, entitySet)
            try
                fields = symphonyui.ui.util.desc2field(entitySet.getPropertyDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.updateProperties(fields);
        end

        function onViewSetProperty(obj, ~, event)
            p = event.data.Property;
            try
                obj.detailedEntitySet.setProperty(p.Name, p.Value);
            catch x
                obj.view.showError(x.message);
                return;
            end
            obj.updatePropertiesForEntitySet(obj.detailedEntitySet);
        end

        function onViewSelectedAddProperty(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddPropertyPresenter(obj.detailedEntitySet);
            presenter.goWaitStop();

            if ~isempty(presenter.result)
                obj.populatePropertiesForEntitySet(obj.detailedEntitySet);
            end
        end

        function onViewSelectedRemoveProperty(obj, ~, ~)
            key = obj.view.getSelectedProperty();
            if isempty(key)
                return;
            end
            try
                tf = obj.detailedEntitySet.removeProperty(key);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            if tf
                obj.populatePropertiesForEntitySet(obj.detailedEntitySet);
            end
        end
        
        function onViewSelectedShowHidePropertyDescription(obj, ~, ~)
            tf = obj.view.getShowPropertyDescription();
            obj.view.setShowPropertyDescription(~tf);
        end

        function populateKeywordsForEntitySet(obj, entitySet)
            keywords = entitySet.keywords;
            
            data = cell(numel(keywords), 1);
            for i = 1:numel(keywords)
                data{i, 1} = keywords{i};
            end            
            obj.view.setKeywords(data);
        end

        function onViewSelectedAddKeyword(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddKeywordPresenter(obj.detailedEntitySet);
            presenter.goWaitStop();

            if ~isempty(presenter.result)
                keyword = presenter.result;
                obj.view.addKeyword(keyword);
            end
        end

        function onViewSelectedRemoveKeyword(obj, ~, ~)
            keyword = obj.view.getSelectedKeyword();
            if isempty(keyword)
                return;
            end
            try
                obj.detailedEntitySet.removeKeyword(keyword);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            obj.view.removeKeyword(keyword);
        end

        function populateNotesForEntitySet(obj, entitySet)
            notes = entitySet.notes;

            data = cell(numel(notes), 2);
            for i = 1:numel(notes)
                data{i, 1} = strtrim(datestr(notes{i}.time, 14));
                data{i, 2} = notes{i}.text;
            end
            obj.view.setNotes(data);
        end

        function onViewSelectedAddNote(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddNotePresenter(obj.detailedEntitySet);
            presenter.goWaitStop();

            if ~isempty(presenter.result)
                note = presenter.result;
                obj.view.addNote(strtrim(datestr(note.time, 14)), note.text);
            end
        end
        
        function populatePresetsForEntitySet(obj, entitySet)
            obj.view.setPresets({});
        end
        
        function onViewSelectedPreset(obj, ~, ~)
            disp('Selected preset');
        end
        
        function onViewSelectedAddPreset(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddEntityPresetPresenter();
            presenter.goWaitStop();
        end
        
        function onViewSelectedManagePresets(obj, ~, ~)
            disp('Selected manage presets');
        end

        function onViewSelectedSendEntityToWorkspace(obj, ~, ~)
            nodes = obj.view.getSelectedNodes();
            assert(numel(nodes) == 1, 'Expected a single entity');

            entity = obj.view.getNodeEntity(nodes(1));
            try
                obj.documentationService.sendEntityToWorkspace(entity);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onViewSelectedDeleteEntity(obj, ~, ~)
            nodes = obj.view.getSelectedNodes();
            assert(numel(nodes) == 1, 'Expected a single entity');

            name = obj.view.getNodeName(nodes(1));
            result = obj.view.showMessage( ...
                ['Are you sure you want to delete ''' name '''?'], ...
                'Delete Entity', ...
                'Cancel', 'Delete');
            if ~strcmp(result, 'Delete')
                return;
            end

            entity = obj.view.getNodeEntity(nodes(1));
            try
                obj.documentationService.deleteEntity(entity);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onServiceDeletedEntity(obj, ~, event)
            uuid = event.data;
            node = obj.uuidToNode(uuid);

            obj.view.removeNode(node);
            obj.uuidToNode.remove(uuid);
            
            obj.populateDetailsForNodes(obj.view.getSelectedNodes());
            obj.updateStateOfControls();
        end

        function onViewSelectedOpenAxesInNewWindow(obj, ~, ~)
            obj.view.openEpochDataAxesInNewWindow();
        end

        function onServiceChangedControllerState(obj, ~, ~)
            obj.updateStateOfControls();

            state = obj.acquisitionService.getControllerState();
            if state.isPaused() || state.isStopped()
                group = obj.documentationService.getCurrentEpochGroup();
                if isempty(group)
                    return;
                end
                obj.updateEpochGroupNode(group);
            end
        end

        function updateStateOfControls(obj)
            sources = obj.documentationService.getExperiment().allSources;
            hasSource = ~isempty(sources);
            hasEpochGroup = ~isempty(obj.documentationService.getCurrentEpochGroup());
            controllerState = obj.acquisitionService.getControllerState();
            isStopped = controllerState.isStopped();
            currentGroup = obj.documentationService.getCurrentEpochGroup();
            
            enableConfigureDevices = isStopped;
            enableAddSource = isStopped;
            enableBeginEpochGroup = hasSource && isStopped;
            enableEndEpochGroup = hasEpochGroup && isStopped;
            
            obj.view.enableConfigureDevicesTool(enableConfigureDevices);
            obj.view.enableAddSourceTool(enableAddSource);
            for i = 1:numel(sources)
                obj.view.enableAddSourceMenu(obj.uuidToNode(sources{i}.uuid), enableAddSource);
            end
            obj.view.enableBeginEpochGroupTool(enableBeginEpochGroup);
            obj.view.enableBeginEpochGroupMenu(obj.view.getExperimentNode(), enableBeginEpochGroup);
            obj.view.enableBeginEpochGroupMenu(obj.view.getEpochGroupsFolderNode(), enableBeginEpochGroup);
            obj.view.enableEndEpochGroupTool(enableEndEpochGroup);
            if ~isempty(currentGroup)
                obj.view.enableBeginEpochGroupMenu(obj.uuidToNode(currentGroup.uuid), enableBeginEpochGroup);
                obj.view.enableEndEpochGroupMenu(obj.uuidToNode(currentGroup.uuid), enableEndEpochGroup);
            end
        end

        function loadSettings(obj)
            if ~isempty(obj.settings.viewPosition)
                obj.view.position = obj.settings.viewPosition;
            end
        end

        function saveSettings(obj)
            obj.settings.viewPosition = obj.view.position;
            obj.settings.save();
        end

    end

end

function map = map2pmap(map)
    keys = map.keys;
    for i = 1:numel(keys)
        k = keys{i};
        v = map(k);
        if iscell(v)
            for j = 1:numel(v)
                if ismatrix(v{j})
                    v{j} = mat2str(v{j});
                elseif isnumeric(v{j})
                    v{j} = num2str(v{j});
                end
            end
            if ~iscellstr(v)
                v = '...';
            end
            map(k) = v;
        end
    end
end
