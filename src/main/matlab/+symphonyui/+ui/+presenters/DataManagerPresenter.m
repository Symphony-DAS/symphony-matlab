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
            obj.addListener(v, 'SelectedEpochGroupSource', @obj.onViewSelectedEpochGroupSource);
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
            obj.addListener(d, 'AddedEntityPreset', @obj.onServiceAddedEntityPreset);
            obj.addListener(d, 'RemovedEntityPreset', @obj.onServiceRemovedEntityPreset);
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
            obj.populateDetailsForExperimentSet(symphonyui.core.persistent.collections.ExperimentSet(experiment));
        end

        function onViewSelectedConfigureDevices(obj, ~, ~)
            presenter = symphonyui.ui.presenters.DevicesPresenter(obj.configurationService);
            presenter.goWaitStop();
        end

        function onViewSelectedAddSource(obj, ~, ~)
            selectedParent = [];
            entitySet = obj.getSelectedEntitySet();
            if entitySet.size == 1 && entitySet.getEntityType() == symphonyui.core.persistent.EntityType.SOURCE
                selectedParent = entitySet.get(1);
            end

            presenter = symphonyui.ui.presenters.AddSourcePresenter(obj.documentationService, selectedParent);
            presenter.goWaitStop();
        end

        function onServiceAddedSource(obj, ~, event)
            source = event.data;
            node = obj.addSourceNode(source);
            
            obj.view.stopEditingProperties();
            obj.view.resetSelectedPreset();
            obj.view.update();
            obj.view.setSelectedNodes(node);

            obj.populateDetailsForSourceSet(symphonyui.core.persistent.collections.SourceSet(source));
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

        function populateDetailsForSourceSet(obj, sourceSet)
            obj.view.enableSourceLabel(sourceSet.size == 1);
            obj.view.setSourceLabel(sourceSet.label);
            obj.view.setCardSelection(obj.view.SOURCE_CARD);

            obj.populateCommonDetailsForEntitySet(sourceSet);
        end

        function onViewSetSourceLabel(obj, ~, ~)
            sourceSet = obj.getSelectedEntitySet();
            try
                sourceSet.label = obj.view.getSourceLabel();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            obj.updateNodeNamesForSourceSet(sourceSet);
        end

        function updateNodeNamesForSourceSet(obj, sourceSet)
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

        function populateDetailsForExperimentSet(obj, experimentSet)
            obj.view.enableExperimentPurpose(experimentSet.size == 1);
            obj.view.setExperimentPurpose(experimentSet.purpose);
            obj.view.setExperimentStartTime(strtrim(datestr(experimentSet.startTime, 14)));
            obj.view.setExperimentEndTime(strtrim(datestr(experimentSet.endTime, 14)));
            obj.view.setCardSelection(obj.view.EXPERIMENT_CARD);

            obj.populateCommonDetailsForEntitySet(experimentSet);
        end

        function onViewSetExperimentPurpose(obj, ~, ~)
            experimentSet = obj.getSelectedEntitySet();
            try
                experimentSet.purpose = obj.view.getExperimentPurpose();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            obj.updateNodeNamesForExperimentSet(experimentSet);
        end

        function updateNodeNamesForExperimentSet(obj, experimentSet)
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
            obj.view.resetSelectedPreset();
            obj.view.update();
            obj.view.setSelectedNodes(node);
            obj.view.setEpochGroupNodeCurrent(node);

            obj.populateDetailsForEpochGroupSet(symphonyui.core.persistent.collections.EpochGroupSet(group));
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
            obj.view.resetSelectedPreset();
            obj.view.update();
            obj.view.setSelectedNodes(node);
            obj.view.collapseNode(node);
            obj.view.setEpochGroupNodeNormal(node);

            obj.populateDetailsForEpochGroupSet(symphonyui.core.persistent.collections.EpochGroupSet(group));
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

        function populateDetailsForEpochGroupSet(obj, groupSet)
            allSources = obj.documentationService.getExperiment().allSources;
            
            obj.view.enableEpochGroupLabel(groupSet.size == 1);
            obj.view.setEpochGroupLabel(groupSet.label);
            obj.view.setEpochGroupStartTime(strtrim(datestr(groupSet.startTime, 14)));
            obj.view.setEpochGroupEndTime(strtrim(datestr(groupSet.endTime, 14)));
            obj.view.enableSelectEpochGroupSource(groupSet.size == 1);
            obj.view.setEpochGroupSourceList(cellfun(@(s)s.label, allSources, 'UniformOutput', false), allSources);
            obj.view.setSelectedEpochGroupSource(groupSet.source);
            obj.view.setCardSelection(obj.view.EPOCH_GROUP_CARD);

            obj.populateCommonDetailsForEntitySet(groupSet);
        end

        function onViewSetEpochGroupLabel(obj, ~, ~)
            groupSet = obj.getSelectedEntitySet();
            try
                groupSet.label = obj.view.getEpochGroupLabel();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            obj.updateNodeNamesForEpochGroupSet(groupSet);
        end
        
        function onViewSelectedEpochGroupSource(obj, ~, ~)
            groupSet = obj.getSelectedEntitySet();
            try
                groupSet.source = obj.view.getSelectedEpochGroupSource();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            obj.updateNodeNamesForEpochGroupSet(groupSet);
        end

        function updateNodeNamesForEpochGroupSet(obj, groupSet)
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

        function populateDetailsForEpochBlockSet(obj, blockSet)
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

        function populateDetailsForEpochSet(obj, epochSet)
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

        function populateDetailsForHeterogeneousEntitySet(obj, entitySet)
            obj.view.setEmptyText('');
            obj.view.setCardSelection(obj.view.EMPTY_CARD);

            obj.populateCommonDetailsForEntitySet(entitySet);
        end

        function onViewSelectedNodes(obj, ~, ~)            
            obj.view.stopEditingProperties();
            obj.view.resetSelectedPreset();
            obj.view.update();
            
            entitySet = obj.getSelectedEntitySet();
            obj.populateDetailsForEntitySet(entitySet);
        end
        
        function populateDetailsForEntitySet(obj, entitySet)
            import symphonyui.core.persistent.EntityType;
            
            if entitySet.size == 0
                obj.populateDetailsForHeterogeneousEntitySet(entitySet);
                return;
            end
            
            switch entitySet.getEntityType()
                case EntityType.SOURCE
                    obj.populateDetailsForSourceSet(entitySet);
                case EntityType.EXPERIMENT
                    obj.populateDetailsForExperimentSet(entitySet);
                case EntityType.EPOCH_GROUP
                    obj.populateDetailsForEpochGroupSet(entitySet);
                case EntityType.EPOCH_BLOCK
                    obj.populateDetailsForEpochBlockSet(entitySet);
                case EntityType.EPOCH
                    obj.populateDetailsForEpochSet(entitySet);
                otherwise
                    obj.populateDetailsForHeterogeneousEntitySet(entitySet);                
            end
        end

        function populateCommonDetailsForEntitySet(obj, entitySet)
            obj.populatePropertiesForEntitySet(entitySet);
            obj.populateKeywordsForEntitySet(entitySet);
            obj.populateNotesForEntitySet(entitySet);
            obj.populatePresetsForEntitySet(entitySet);
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
            entitySet = obj.getSelectedEntitySet();
            try
                entitySet.setProperty(p.Name, p.Value);
            catch x
                obj.view.showError(x.message);
                return;
            end
            obj.updatePropertiesForEntitySet(entitySet);
        end

        function onViewSelectedAddProperty(obj, ~, ~)
            entitySet = obj.getSelectedEntitySet();
            presenter = symphonyui.ui.presenters.AddPropertyPresenter(entitySet);
            presenter.goWaitStop();
            
            if ~isempty(presenter.result)
                obj.populatePropertiesForEntitySet(entitySet);
            end
        end

        function onViewSelectedRemoveProperty(obj, ~, ~)
            key = obj.view.getSelectedProperty();
            if ~ischar(key)
                return;
            end
            
            entitySet = obj.getSelectedEntitySet();
            try
                tf = entitySet.removeProperty(key);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            if tf
                obj.populatePropertiesForEntitySet(entitySet);
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
            entitySet = obj.getSelectedEntitySet();
            presenter = symphonyui.ui.presenters.AddKeywordPresenter(entitySet);
            presenter.goWaitStop();

            if ~isempty(presenter.result)
                keyword = presenter.result;
                obj.view.addKeyword(keyword);
            end
        end

        function onViewSelectedRemoveKeyword(obj, ~, ~)
            keyword = obj.view.getSelectedKeyword();
            if ~ischar(keyword)
                return;
            end
            
            entitySet = obj.getSelectedEntitySet();
            try
                entitySet.removeKeyword(keyword);
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
            entitySet = obj.getSelectedEntitySet();
            presenter = symphonyui.ui.presenters.AddNotePresenter(entitySet);
            presenter.goWaitStop();

            if ~isempty(presenter.result)
                note = presenter.result;
                obj.view.addNote(strtrim(datestr(note.time, 14)), note.text);
            end
        end

        function populatePresetsForEntitySet(obj, entitySet)
            presets = obj.documentationService.getAvailableEntityPresets(entitySet.getEntityType(), entitySet.getDescriptionType());
            obj.view.setPresetList(presets, presets);
            obj.view.enableSelectPreset(entitySet.size == 1);
        end

        function onViewSelectedPreset(obj, ~, ~)
            import symphonyui.core.persistent.EntityType;
            
            entitySet = obj.getSelectedEntitySet();

            name = obj.view.getSelectedPreset();
            try
                preset = obj.documentationService.getEntityPreset(name, entitySet.getEntityType(), entitySet.getDescriptionType());
                entitySet.applyPreset(preset);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            obj.populateDetailsForEntitySet(entitySet);
            
            switch entitySet.getEntityType()
                case EntityType.SOURCE
                    obj.updateNodeNamesForSourceSet(entitySet);
                case EntityType.EXPERIMENT
                    obj.updateNodeNamesForExperimentSet(entitySet);
                case EntityType.EPOCH_GROUP
                    obj.updateNodeNamesForEpochGroupSet(entitySet);            
            end
        end

        function onViewSelectedAddPreset(obj, ~, ~)
            obj.view.stopEditingProperties();
            obj.view.update();
            
            entitySet = obj.getSelectedEntitySet();
            presenter = symphonyui.ui.presenters.AddEntityPresetPresenter(obj.documentationService, entitySet);
            presenter.goWaitStop();
        end

        function onServiceAddedEntityPreset(obj, ~, ~)
            entitySet = obj.getSelectedEntitySet();
            obj.populatePresetsForEntitySet(entitySet);
        end

        function onViewSelectedManagePresets(obj, ~, ~)
            entitySet = obj.getSelectedEntitySet();
            presenter = symphonyui.ui.presenters.EntityPresetsPresenter(obj.documentationService, entitySet);
            presenter.goWaitStop();
        end

        function onServiceRemovedEntityPreset(obj, ~, ~)
            entitySet = obj.getSelectedEntitySet();
            obj.populatePresetsForEntitySet(entitySet);
        end

        function onViewSelectedSendEntityToWorkspace(obj, ~, ~)
            entitySet = obj.getSelectedEntitySet();
            for i = 1:entitySet.size
                try
                    obj.documentationService.sendEntityToWorkspace(entitySet.get(i));
                catch x
                    obj.log.debug(x.message, x);
                    obj.view.showError(x.message);
                    return;
                end
            end
        end

        function onViewSelectedDeleteEntity(obj, ~, ~)
            nodes = obj.view.getSelectedNodes();
            
            names = cell(1, numel(nodes));
            entities = cell(1, numel(nodes));
            for i = 1:numel(nodes)
                names{i} = obj.view.getNodeName(nodes(i));
                entities{i} = obj.view.getNodeEntity(nodes(i));
            end
            
            result = obj.view.showMessage( ...
                ['Are you sure you want to delete ''' strjoin(names, ',') '''?'], ...
                'Delete Entity', ...
                'Cancel', 'Delete');
            if ~strcmp(result, 'Delete')
                return;
            end

            for i = 1:numel(entities)
                try
                    if isequal(entities{i}, obj.documentationService.getCurrentEpochGroup())
                        obj.documentationService.endEpochGroup();
                    end
                    obj.documentationService.deleteEntity(entities{i});
                catch x
                    obj.log.debug(x.message, x);
                    obj.view.showError(x.message);
                    return;
                end
            end
        end

        function onServiceDeletedEntity(obj, ~, event)
            uuid = event.data;
            node = obj.uuidToNode(uuid);

            obj.view.removeNode(node);
            obj.uuidToNode.remove(uuid);
            
            entitySet = obj.getSelectedEntitySet();
            obj.populateDetailsForEntitySet(entitySet);
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
        
        function s = getSelectedEntitySet(obj)
            import symphonyui.ui.views.EntityNodeType;
            import symphonyui.core.persistent.collections.*;
            
            nodes = obj.view.getSelectedNodes();
            
            entities = {};
            types = EntityNodeType.empty(0, numel(nodes));
            for i = 1:numel(nodes)
                entity = obj.view.getNodeEntity(nodes(i));
                if ~isempty(entity)
                    entities{end + 1} = entity; %#ok<AGROW>
                end
                types(i) = obj.view.getNodeType(nodes(i));
            end
            
            types = unique(types);
            if numel(types) ~= 1
                s = EntitySet({});
                return;
            end
            type = types(1);
            
            switch type
                case EntityNodeType.SOURCE
                    s = SourceSet(entities);
                case EntityNodeType.EXPERIMENT
                    s = ExperimentSet(entities);
                case EntityNodeType.EPOCH_GROUP
                    s = EpochGroupSet(entities);
                case EntityNodeType.EPOCH_BLOCK
                    s = EpochBlockSet(entities);
                case EntityNodeType.EPOCH
                    s = EpochSet(entities);
                otherwise
                    s = EntitySet(entities);
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
