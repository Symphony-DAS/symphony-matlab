classdef MainPresenter < symphonyui.ui.Presenter

    properties (Access = private)
        log
        settings
        documentationService
        acquisitionService
        configurationService
        moduleService
        dataManagerPresenter
        protocolPreview
    end

    methods

        function obj = MainPresenter(documentationService, acquisitionService, configurationService, moduleService, view)
            if nargin < 5
                view = symphonyui.ui.views.MainView();
            end
            obj = obj@symphonyui.ui.Presenter(view);

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

        function onGoing(obj)
            obj.updateStateOfControls();
            obj.populateProtocolList();
            obj.populateProtocolProperties();
            obj.populateModuleList();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
        end

        function onStopping(obj)
            if ~isempty(obj.dataManagerPresenter)
                obj.closeDataManager();
            end
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save presenter settings: ' x.message], x);
            end
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'NewFile', @obj.onViewSelectedNewFile);
            obj.addListener(v, 'OpenFile', @obj.onViewSelectedOpenFile);
            obj.addListener(v, 'CloseFile', @obj.onViewSelectedCloseFile);
            obj.addListener(v, 'Exit', @obj.onViewSelectedExit);
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'SelectedProtocol', @obj.onViewSelectedProtocol);
            obj.addListener(v, 'SetProtocolProperty', @obj.onViewSetProtocolProperty);
            obj.addListener(v, 'MinimizeProtocolPreview', @obj.onViewSelectedMinimizeProtocolPreview);
            obj.addListener(v, 'ViewOnly', @obj.onViewSelectedViewOnly);
            obj.addListener(v, 'Record', @obj.onViewSelectedRecord);
            obj.addListener(v, 'Pause', @obj.onViewSelectedPause);
            obj.addListener(v, 'Stop', @obj.onViewSelectedStop);
            obj.addListener(v, 'InitializeRig', @obj.onViewSelectedInitializeRig);
            obj.addListener(v, 'ConfigureDeviceBackgrounds', @obj.onViewSelectedConfigureDeviceBackgrounds);
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
            obj.addListener(a, 'SetProtocolProperty', @obj.onServiceSetProtocolProperty);
            obj.addListener(a, 'ChangedControllerState', @obj.onServiceChangedControllerState);

            c = obj.configurationService;
            obj.addListener(c, 'InitializedRig', @obj.onServiceInitializedRig);
        end

    end

    methods (Access = private)

        function onViewSelectedNewFile(obj, ~, ~)
            presenter = symphonyui.ui.presenters.NewFilePresenter(obj.documentationService);
            presenter.goWaitStop();
        end

        function onServiceCreatedFile(obj, ~, ~)
            obj.updateStateOfControls();
            obj.showDataManager();
        end

        function onViewSelectedOpenFile(obj, ~, ~)
            obj.openFile();
        end

        function openFile(obj)
            path = obj.view.showGetFile('File Location');
            if isempty(path)
                return;
            end
            try
                obj.documentationService.openFile(path);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onServiceOpenedFile(obj, ~, ~)
            obj.updateStateOfControls();
            obj.showDataManager();
        end

        function onViewSelectedCloseFile(obj, ~, ~)
            obj.closeFile();
        end

        function closeFile(obj)
            if ~obj.documentationService.hasOpenFile()
                return;
            end
            try
                obj.documentationService.closeFile();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onServiceClosedFile(obj, ~, ~)
            obj.updateStateOfControls();
            obj.closeDataManager();
        end

        function onViewSelectedExit(obj, ~, ~)
            obj.stop();
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

        function onServiceDeletedEntity(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function showDataManager(obj)
            presenter = symphonyui.ui.presenters.DataManagerPresenter(obj.documentationService, obj.acquisitionService);
            addlistener(presenter, 'Stopped', @(h,d)obj.closeFile());
            presenter.go();
            obj.dataManagerPresenter = presenter;
        end

        function closeDataManager(obj)
            obj.dataManagerPresenter.stop();
            obj.dataManagerPresenter = [];
        end

        function populateProtocolList(obj)
            classNames = obj.acquisitionService.getAvailableProtocols();

            displayNames = cell(1, numel(classNames));
            for i = 1:numel(classNames)
                split = strsplit(classNames{i}, '.');
                displayNames{i} = symphonyui.core.util.humanize(split{end});
            end
            
            for i = 1:numel(displayNames)
                name = displayNames{i};
                repeats = find(strcmp(name, displayNames));
                if numel(repeats) > 1
                    for j = 1:numel(repeats)
                        displayNames{repeats(j)} = [name ' (' classNames{repeats(j)} ')'];
                    end
                end
            end
            
            obj.view.setProtocolList([{'(None)'}, displayNames], [{[]}, classNames]);
            obj.view.setSelectedProtocol(obj.acquisitionService.getSelectedProtocol());
            obj.view.enableSelectProtocol(numel(classNames) > 0);
        end

        function onViewSelectedProtocol(obj, ~, ~)
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

        function onServiceSetProtocolProperty(obj, ~, ~)
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
            obj.view.setHeight(obj.view.getHeight() - delta);
            obj.view.setProtocolPreviewHeight(obj.view.getProtocolPreviewHeight() - delta);
            obj.view.enableProtocolLayoutDivider(false);
            obj.view.setProtocolPreviewMinimized(true);
        end

        function maximizeProtocolPreview(obj)
            delta = 253;
            obj.view.setHeight(obj.view.getHeight() + delta);
            obj.view.setProtocolPreviewHeight(obj.view.getProtocolPreviewHeight() + delta);
            obj.view.enableProtocolLayoutDivider(true);
            obj.view.setProtocolPreviewMinimized(false);
        end

        function onViewSelectedViewOnly(obj, ~, ~)
            obj.view.stopEditingProtocolProperties();
            obj.view.update();
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
                obj.acquisitionService.record();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedPause(obj, ~, ~)
            try
                obj.acquisitionService.pause();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onViewSelectedStop(obj, ~, ~)
            try
                obj.acquisitionService.stop();
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
            hasSource = hasOpenFile && ~isempty(obj.documentationService.getExperiment().sources);
            hasEpochGroup = hasOpenFile && ~isempty(obj.documentationService.getCurrentEpochGroup());
            hasAvailableProtocol = ~isempty(obj.acquisitionService.getAvailableProtocols());
            controllerState = obj.acquisitionService.getControllerState();
            isPausing = controllerState == ControllerState.PAUSING;
            isViewingPaused = controllerState == ControllerState.VIEWING_PAUSED;
            isRecordingPaused = controllerState == ControllerState.RECORDING_PAUSED;
            isStopping = controllerState == ControllerState.STOPPING;
            isStopped = controllerState == ControllerState.STOPPED;
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
            enableSelectProtocol = hasAvailableProtocol && isStopped;
            enableProtocolProperties = isStopped;
            enableViewOnly = isValid && (isViewingPaused || isStopped);
            enableRecord = isValid && hasEpochGroup && (isRecordingPaused || isStopped);
            enablePause = ~isPausing && ~isViewingPaused && ~isRecordingPaused && ~isStopping && ~isStopped;
            enableStop = ~isStopping && ~isStopped;
            enableInitializeRig = isStopped;
            enableConfigureDeviceBackgrounds = isStopped;

            if ~isValid
                status = validationMessage;
            elseif isStopped
                status = '';
            else
                status = char(controllerState);
            end

            obj.view.enableNewFile(enableNewFile);
            obj.view.enableOpenFile(enableOpenFile);
            obj.view.enableCloseFile(enableCloseFile);
            obj.view.enableAddSource(enableAddSource);
            obj.view.enableBeginEpochGroup(enableBeginEpochGroup);
            obj.view.enableEndEpochGroup(enableEndEpochGroup);
            obj.view.enableSelectProtocol(enableSelectProtocol);
            obj.view.enableProtocolProperties(enableProtocolProperties);
            obj.view.enableViewOnly(enableViewOnly);
            obj.view.enableRecord(enableRecord);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.enableInitializeRig(enableInitializeRig);
            obj.view.enableConfigureDeviceBackgrounds(enableConfigureDeviceBackgrounds);
            obj.view.setStatus(status);
        end

        function onViewSelectedInitializeRig(obj, ~, ~)
            obj.showInitializeRig();
        end

        function onServiceInitializedRig(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function onViewSelectedConfigureDeviceBackgrounds(obj, ~, ~)
            presenter = symphonyui.ui.presenters.DeviceBackgroundsPresenter(obj.configurationService);
            presenter.goWaitStop();
        end

        function onViewSelectedConfigureOptions(obj, ~, ~) %#ok<INUSD>
            presenter = symphonyui.ui.presenters.OptionsPresenter(symphonyui.app.Options.getDefault());
            presenter.goWaitStop();
        end

        function populateModuleList(obj)
            classNames = obj.moduleService.getAvailableModules();

            displayNames = cell(1, numel(classNames));
            for i = 1:numel(classNames)
                split = strsplit(classNames{i}, '.');
                displayNames{i} = symphonyui.core.util.humanize(split{end});
            end

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
            obj.view.showWeb(symphonyui.app.App.documentationUrl);
        end

        function onViewSelectedShowUserGroup(obj, ~, ~)
            obj.view.showWeb(symphonyui.app.App.userGroupUrl);
        end

        function onViewSelectedShowAbout(obj, ~, ~)
            message = sprintf('%s\nVersion %s\n%s', ...
                symphonyui.app.App.title, ...
                symphonyui.app.App.version, ...
                symphonyui.app.App.copyright);
            obj.view.showMessage(message, 'About Symphony');
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
