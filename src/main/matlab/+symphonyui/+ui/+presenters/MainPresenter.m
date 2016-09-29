classdef MainPresenter < appbox.Presenter

    properties (Access = private)
        log
        settings
        documentationService
        acquisitionService
        configurationService
        moduleService
        protocolPresetsPresenter
        dataManagerPresenter
        protocolPreview
    end

    methods

        function obj = MainPresenter(documentationService, acquisitionService, configurationService, moduleService, view)
            if nargin < 5
                view = symphonyui.ui.views.MainView();
            end
            obj = obj@appbox.Presenter(view);

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.MainSettings();
            obj.documentationService = documentationService;
            obj.acquisitionService = acquisitionService;
            obj.configurationService = configurationService;
            obj.moduleService = moduleService;
        end

        function showInitializeRig(obj)
            presenter = symphonyui.ui.presenters.InitializeRigPresenter(obj.configurationService);
            presenter.goWaitStop();
        end

        function selectProtocol(obj, className)
            obj.view.stopEditingProtocolProperties();
            obj.view.update();
            try
                obj.acquisitionService.selectProtocol(className);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                obj.acquisitionService.selectProtocol([]);
                return;
            end
        end

    end

    methods (Access = protected)

        function willGo(obj)
            obj.populateProtocolList();
            obj.populateProtocolProperties();
            obj.populateModuleList();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
            obj.updateStateOfControls();
        end

        function willStop(obj)
            if ~isempty(obj.protocolPresetsPresenter)
                obj.closeProtocolPresets();
            end
            if ~isempty(obj.dataManagerPresenter)
                obj.closeDataManager();
            end
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save presenter settings: ' x.message], x);
            end
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'NewFile', @obj.onViewSelectedNewFile);
            obj.addListener(v, 'OpenFile', @obj.onViewSelectedOpenFile);
            obj.addListener(v, 'CloseFile', @obj.onViewSelectedCloseFile);
            obj.addListener(v, 'Exit', @obj.onViewSelectedExit);
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'AddNoteToExperiment', @obj.onViewSelectedAddNoteToExperiment);
            obj.addListener(v, 'SelectedProtocol', @obj.onViewSelectedProtocol);
            obj.addListener(v, 'SetProtocolProperty', @obj.onViewSetProtocolProperty);
            obj.addListener(v, 'MinimizeProtocolPreview', @obj.onViewSelectedMinimizeProtocolPreview);
            obj.addListener(v, 'ViewOnly', @obj.onViewSelectedViewOnly);
            obj.addListener(v, 'Record', @obj.onViewSelectedRecord);
            obj.addListener(v, 'Pause', @obj.onViewSelectedPause);
            obj.addListener(v, 'Stop', @obj.onViewSelectedStop);
            obj.addListener(v, 'ResetProtocol', @obj.onViewSelectedResetProtocol);
            obj.addListener(v, 'ShowProtocolPresets', @obj.onViewSelectedShowProtocolPresets);
            obj.addListener(v, 'InitializeRig', @obj.onViewSelectedInitializeRig);
            obj.addListener(v, 'ConfigureDevices', @obj.onViewSelectedConfigureDevices);
            obj.addListener(v, 'ConfigureOptions', @obj.onViewSelectedConfigureOptions);
            obj.addListener(v, 'SelectedModule', @obj.onViewSelectedModule);
            obj.addListener(v, 'ShowDocumentation', @obj.onViewSelectedShowDocumentation);
            obj.addListener(v, 'ShowUserGroup', @obj.onViewSelectedShowUserGroup);
            obj.addListener(v, 'ShowAbout', @obj.onViewSelectedShowAbout);

            d = obj.documentationService;
            obj.addListener(d, 'CreatedFile', @obj.onServiceCreatedFile);
            obj.addListener(d, 'OpenedFile', @obj.onServiceOpenedFile);
            obj.addListener(d, 'ClosedFile', @obj.onServiceClosedFile);
            obj.addListener(d, 'AddedSource', @obj.onServiceAddedSource);
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);
            obj.addListener(d, 'DeletedEntity', @obj.onServiceDeletedEntity);

            a = obj.acquisitionService;
            obj.addListener(a, 'SelectedProtocol', @obj.onServiceSelectedProtocol);
            obj.addListener(a, 'SetProtocolProperties', @obj.onServiceSetProtocolProperties);
            obj.addListener(a, 'AppliedProtocolPreset', @obj.onServiceAppliedProtocolPreset);
            obj.addListener(a, 'ChangedControllerState', @obj.onServiceChangedControllerState);

            c = obj.configurationService;
            obj.addListener(c, 'InitializedRig', @obj.onServiceInitializedRig);
        end

        function onViewSelectedClose(obj, ~, ~)
            obj.exit();
        end

    end

    methods (Access = private)

        function onViewSelectedNewFile(obj, ~, ~)
            options = obj.configurationService.getOptions();
            presenter = symphonyui.ui.presenters.NewFilePresenter(obj.documentationService, options);
            presenter.goWaitStop();
        end

        function onServiceCreatedFile(obj, ~, ~)
            obj.updateStateOfControls();
            obj.showDataManager();
        end

        function onViewSelectedOpenFile(obj, ~, ~)
            obj.openFile();
        end

        function tf = openFile(obj)
            tf = false;
            path = obj.view.showGetFile('File Location');
            if isempty(path)
                return;
            end
            p = obj.view.showBusy('Opening file...');
            d = onCleanup(@()delete(p));
            try
                obj.documentationService.openFile(path);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            tf = true;
        end

        function onServiceOpenedFile(obj, ~, ~)
            obj.updateStateOfControls();
            obj.showDataManager();
        end

        function onViewSelectedCloseFile(obj, ~, ~)
            obj.closeFile();
        end

        function tf = closeFile(obj)
            tf = false;
            
            experiment = obj.documentationService.getExperiment();
            entities = [{experiment}, experiment.getAllSources(), experiment.getAllEpochGroups()];
            n = 0;
            for i = 1:numel(entities)
                if any(arrayfun(@(d)d.isPreferred && isempty(d.value), entities{i}.getPropertyDescriptors()))
                    n = n + 1;
                end
            end
            message = '';
            if n > 0
                message = sprintf('%i entities contain empty preferred properties. ', n);
            end
            message = [message, 'Are you sure you want to close the current file?'];

            result = obj.view.showMessage( ...
                message, ...
                'Close File', ...
                'Cancel', 'Close');
            if ~strcmp(result, 'Close')
                return;
            end
            try
                obj.documentationService.closeFile();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            tf = true;
        end

        function onServiceClosedFile(obj, ~, ~)
            obj.updateStateOfControls();
            obj.closeDataManager();
        end

        function onViewSelectedExit(obj, ~, ~)
            obj.exit();
        end

        function exit(obj)
            shouldExit = true;
            controllerState = obj.acquisitionService.getControllerState();
            if ~controllerState.isStopped()
                obj.acquisitionService.requestStop();
            end
            if obj.documentationService.hasOpenFile()
                shouldExit = obj.closeFile();
            end
            if shouldExit
                obj.stop();
            end
        end

        function onViewSelectedAddSource(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddSourcePresenter(obj.documentationService);
            presenter.goWaitStop();
        end

        function onServiceAddedSource(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.documentationService);
            presenter.goWaitStop();
        end

        function onServiceBeganEpochGroup(obj, ~, ~)
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

        function onServiceEndedEpochGroup(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function onViewSelectedAddNoteToExperiment(obj, ~, ~)
            experiment = obj.documentationService.getExperiment();
            experimentSet = symphonyui.core.persistent.collections.EntitySet(experiment);
            presenter = symphonyui.ui.presenters.AddNotePresenter(experimentSet);
            presenter.goWaitStop();
        end

        function onServiceDeletedEntity(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function showDataManager(obj)
            if isempty(obj.dataManagerPresenter) || obj.dataManagerPresenter.isStopped()
                obj.dataManagerPresenter = symphonyui.ui.presenters.DataManagerPresenter(obj.documentationService, obj.acquisitionService, obj.configurationService);
                obj.dataManagerPresenter.viewSelectedCloseFcn = @obj.closeFile;
                obj.dataManagerPresenter.go();
            else
                obj.dataManagerPresenter.show();
            end
        end

        function closeDataManager(obj)
            if ~obj.dataManagerPresenter.isStopped()
                obj.dataManagerPresenter.stop();
            end
            obj.dataManagerPresenter = [];
        end

        function populateProtocolList(obj)
            classNames = obj.acquisitionService.getAvailableProtocols();
            displayNames = appbox.class2display(classNames);

            [displayNames, i] = sort(displayNames);
            classNames = classNames(i);

            obj.view.setProtocolList([{'(None)'}, displayNames], [{[]}, classNames]);
            obj.view.setSelectedProtocol(obj.acquisitionService.getSelectedProtocol());
            obj.view.enableSelectProtocol(numel(classNames) > 0);
        end

        function onViewSelectedProtocol(obj, ~, ~)
            protocol = obj.view.getSelectedProtocol();
            if strcmp(protocol, obj.acquisitionService.getSelectedProtocol())
                return;
            end
            obj.selectProtocol(obj.view.getSelectedProtocol());
        end

        function onServiceSelectedProtocol(obj, ~, ~)
            obj.view.setSelectedProtocol(obj.acquisitionService.getSelectedProtocol());
            obj.updateStateOfControls();
            obj.populateProtocolProperties();
            if ~obj.view.isProtocolPreviewMinimized()
                obj.populateProtocolPreview();
            end
        end

        function populateProtocolProperties(obj)
            try
                fields = symphonyui.ui.util.desc2field(obj.acquisitionService.getProtocolPropertyDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.setProtocolProperties(fields);
        end

        function updateProtocolProperties(obj)
            try
                fields = symphonyui.ui.util.desc2field(obj.acquisitionService.getProtocolPropertyDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.updateProtocolProperties(fields);
        end

        function onViewSetProtocolProperty(obj, ~, event)
            p = event.Property;
            try
                obj.acquisitionService.setProtocolProperty(p.Name, p.Value);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onServiceSetProtocolProperties(obj, ~, ~)
            obj.updateStateOfControls();
            obj.updateProtocolProperties();
            if ~obj.view.isProtocolPreviewMinimized()
                obj.updateProtocolPreview();
            end
        end

        function onServiceAppliedProtocolPreset(obj, ~, ~)
            obj.view.stopEditingProtocolProperties();
            obj.updateStateOfControls();
            obj.updateProtocolProperties();
            if ~obj.view.isProtocolPreviewMinimized()
                obj.updateProtocolPreview();
            end
        end

        function populateProtocolPreview(obj)
            obj.view.clearProtocolPreviewPanel();
            panel = obj.view.getProtocolPreviewPanel();
            try
                obj.protocolPreview = obj.acquisitionService.getProtocolPreview(panel);
            catch x
                obj.protocolPreview = [];
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function updateProtocolPreview(obj)
            if isempty(obj.protocolPreview)
                return;
            end
            try
                obj.protocolPreview.update();
            catch x
                obj.log.debug(x.message, x);
                return;
            end
        end

        function onViewSelectedMinimizeProtocolPreview(obj, ~, ~)
            if obj.view.isProtocolPreviewMinimized()
                obj.maximizeProtocolPreview();
                obj.populateProtocolPreview();
            else
                obj.minimizeProtocolPreview();
                obj.protocolPreview = [];
            end
        end

        function minimizeProtocolPreview(obj)
            delta = obj.view.getProtocolPreviewHeight() - obj.view.getProtocolPreviewMinimumHeight();
            obj.view.setViewHeight(obj.view.getViewHeight() - delta);
            obj.view.setProtocolPreviewHeight(obj.view.getProtocolPreviewHeight() - delta);
            obj.view.enableProtocolLayoutDivider(false);
            obj.view.setProtocolPreviewMinimized(true);
        end

        function maximizeProtocolPreview(obj)
            delta = 253;
            obj.view.setViewHeight(obj.view.getViewHeight() + delta);
            obj.view.setProtocolPreviewHeight(obj.view.getProtocolPreviewHeight() + delta);
            obj.view.enableProtocolLayoutDivider(true);
            obj.view.setProtocolPreviewMinimized(false);
        end

        function onViewSelectedViewOnly(obj, ~, ~)
            obj.view.stopEditingProtocolProperties();
            obj.view.update();
            try
                isValid = obj.acquisitionService.isValid();
            catch
                isValid = false;
            end
            if ~isValid
                obj.updateStateOfControls();
                return;
            end
            options = obj.configurationService.getOptions();
            if obj.documentationService.hasOpenFile() && options.warnOnViewOnlyWithOpenFile
                [result, dontShow] = obj.view.showMessage( ...
                    'Are you sure you want to run "View Only"? No data will be saved to your file.', ...
                    'Warning', ...
                    'Cancel', 'View Only', [], 2, [], ...
                    'Don''t show this message again');
                if ~strcmp(result, 'View Only')
                    return;
                end
                if dontShow
                    options.warnOnViewOnlyWithOpenFile = false;
                end
            end
            try
                obj.acquisitionService.viewOnly();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onViewSelectedRecord(obj, ~, ~)
            obj.view.stopEditingProtocolProperties();
            obj.view.update();
            try
                isValid = obj.acquisitionService.isValid();
            catch
                isValid = false;
            end
            if ~isValid
                obj.updateStateOfControls();
                return;
            end
            try
                obj.acquisitionService.record();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onViewSelectedPause(obj, ~, ~)
            try
                obj.acquisitionService.requestPause();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onViewSelectedStop(obj, ~, ~)
            try
                obj.acquisitionService.requestStop();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onServiceChangedControllerState(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function updateStateOfControls(obj)
            import symphonyui.core.ControllerState;

            hasOpenFile = obj.documentationService.hasOpenFile();
            hasSource = hasOpenFile && ~isempty(obj.documentationService.getExperiment().getSources());
            hasEpochGroup = hasOpenFile && ~isempty(obj.documentationService.getCurrentEpochGroup());
            hasAvailableProtocol = ~isempty(obj.acquisitionService.getAvailableProtocols());
            controllerState = obj.acquisitionService.getControllerState();
            isPausing = controllerState.isPausing();
            isViewingPaused = controllerState.isViewingPaused();
            isRecordingPaused = controllerState.isRecordingPaused();
            isPaused = controllerState.isPaused();
            isStopping = controllerState.isStopping();
            isStopped = controllerState.isStopped();
            try
                [isValid, validationMessage] = obj.acquisitionService.isValid();
            catch x
                isValid = false;
                validationMessage = 'Failed validation';
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end

            enableNewFile = ~hasOpenFile && isStopped;
            enableOpenFile = enableNewFile;
            enableCloseFile = hasOpenFile && isStopped;
            enableAddSource = hasOpenFile && isStopped;
            enableBeginEpochGroup = hasSource && isStopped;
            enableEndEpochGroup = hasEpochGroup && isStopped;
            enableAddNoteToExperiment = hasOpenFile && isStopped;
            enableSelectProtocol = hasAvailableProtocol && isStopped;
            enableProtocolProperties = isStopped;
            enableViewOnly = isValid && (isViewingPaused || isStopped);
            enableRecord = isValid && hasEpochGroup && (isRecordingPaused || isStopped);
            enablePause = ~isPausing && ~isViewingPaused && ~isRecordingPaused && ~isStopping && ~isStopped;
            enableStop = ~isStopping && ~isStopped;
            enableResetProtocol = isStopped;
            enableInitializeRig = isStopped;
            enableConfigureDevices = isStopped;

            if ~isValid
                status = validationMessage;
                statusMode = obj.view.INVALID_STATUS_MODE;
            else
                status = char(controllerState);
                if isStopped || isPaused
                    statusMode = obj.view.VALID_STATUS_MODE;
                else
                    statusMode = obj.view.BUSY_STATUS_MODE;
                end
            end

            obj.view.enableNewFile(enableNewFile);
            obj.view.enableOpenFile(enableOpenFile);
            obj.view.enableCloseFile(enableCloseFile);
            obj.view.enableAddSource(enableAddSource);
            obj.view.enableBeginEpochGroup(enableBeginEpochGroup);
            obj.view.enableEndEpochGroup(enableEndEpochGroup);
            obj.view.enableAddNoteToExperiment(enableAddNoteToExperiment);
            obj.view.enableSelectProtocol(enableSelectProtocol);
            obj.view.enableProtocolProperties(enableProtocolProperties);
            obj.view.enableViewOnly(enableViewOnly);
            obj.view.enableRecord(enableRecord);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.enableResetProtocol(enableResetProtocol);
            obj.view.enableInitializeRig(enableInitializeRig);
            obj.view.enableConfigureDevices(enableConfigureDevices);
            obj.view.setStatus(status);
            obj.view.setStatusMode(statusMode);
        end

        function onViewSelectedResetProtocol(obj, ~, ~)
            try
                obj.acquisitionService.resetProtocol();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onViewSelectedShowProtocolPresets(obj, ~, ~)
            obj.showProtocolPresets();
        end

        function showProtocolPresets(obj)
            if isempty(obj.protocolPresetsPresenter) || obj.protocolPresetsPresenter.isStopped()
                obj.protocolPresetsPresenter = symphonyui.ui.presenters.ProtocolPresetsPresenter(obj.documentationService, obj.acquisitionService);
                obj.protocolPresetsPresenter.go();
            else
                obj.protocolPresetsPresenter.show();
            end
        end

        function closeProtocolPresets(obj)
            if ~obj.protocolPresetsPresenter.isStopped()
                obj.protocolPresetsPresenter.stop();
            end
            obj.protocolPresetsPresenter = [];
        end

        function onViewSelectedInitializeRig(obj, ~, ~)
            obj.showInitializeRig();
        end

        function onServiceInitializedRig(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function onViewSelectedConfigureDevices(obj, ~, ~)
            presenter = symphonyui.ui.presenters.DevicesPresenter(obj.configurationService);
            presenter.goWaitStop();
        end

        function onViewSelectedConfigureOptions(obj, ~, ~)
            options = obj.configurationService.getOptions();
            presenter = symphonyui.ui.presenters.OptionsPresenter(options);
            presenter.goWaitStop();
        end

        function populateModuleList(obj)
            classNames = obj.moduleService.getAvailableModules();
            displayNames = appbox.class2display(classNames, true);

            [displayNames, i] = sort(displayNames);
            classNames = classNames(i);

            for i = 1:numel(classNames)
                obj.view.addModule(displayNames{i}, classNames{i});
            end
        end

        function onViewSelectedModule(obj, ~, event)
            module = event.data;
            try
                obj.moduleService.showModule(module);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
        end

        function onViewSelectedShowDocumentation(obj, ~, ~)
            obj.view.showWeb(symphonyui.app.App.documentationUrl, '-helpbrowser');
        end

        function onViewSelectedShowUserGroup(obj, ~, ~)
            obj.view.showWeb(symphonyui.app.App.userGroupUrl);
        end

        function onViewSelectedShowAbout(obj, ~, ~)
            message = sprintf('%s %s\nVersion %s\n%s', ...
                symphonyui.app.App.name, ...
                symphonyui.app.App.description, ...
                symphonyui.app.App.version, ...
                [char(169) ' ' datestr(now, 'yyyy') ' ' symphonyui.app.App.owner]);
            obj.view.showMessage(message, ['About ' symphonyui.app.App.name]);
        end

        function loadSettings(obj)
            if ~isempty(obj.settings.viewPosition)
                obj.view.position = obj.settings.viewPosition;
            end
        end

        function saveSettings(obj)
            position = obj.view.position;
            if ~obj.view.isProtocolPreviewMinimized()
                delta = obj.view.getProtocolPreviewHeight() - obj.view.getProtocolPreviewMinimumHeight();
                position(2) = position(2) + delta;
                position(4) = position(4) - delta;
            end
            obj.settings.viewPosition = position;
            obj.settings.save();
        end

    end

end
