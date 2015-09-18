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
        
        function openInitializeRig(obj)
            presenter = symphonyui.ui.presenters.InitializeRigPresenter(obj.configurationService);
            presenter.goWaitStop();
        end
        
        function selectProtocol(obj, className)
            try
                obj.acquisitionService.selectProtocol(className);
            catch x
                obj.updateStateOfControls();
                obj.populateProtocolProperties();
                if ~obj.view.isProtocolPreviewMinimized()
                    obj.populateProtocolPreview();
                end
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
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
                obj.log.debug(x.message, x);
            end
        end

        function onStopping(obj)
            if ~isempty(obj.dataManagerPresenter)
                obj.closeDataManager();
            end
            obj.saveSettings();
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
            obj.addListener(a, 'ChangedState', @obj.onServiceChangedState);

            c = obj.configurationService;
            obj.addListener(c, 'InitializedRig', @obj.onServiceInitializedRig);
        end

    end

    methods (Access = private)
        
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

        function onViewSelectedNewFile(obj, ~, ~)
            presenter = symphonyui.ui.presenters.NewFilePresenter(obj.documentationService);
            presenter.goWaitStop();
        end

        function onServiceCreatedFile(obj, ~, ~)
            obj.updateStateOfControls();
            obj.openDataManager();
        end

        function onViewSelectedOpenFile(obj, ~, ~)
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
            obj.openDataManager();
        end

        function onViewSelectedCloseFile(obj, ~, ~)
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

        function openDataManager(obj)
            presenter = symphonyui.ui.presenters.DataManagerPresenter(obj.documentationService);
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
            
            if numel(classNames) > 0
                obj.view.setProtocolList(displayNames, classNames);
            else
                obj.view.setProtocolList({'(None)'}, {[]});
            end
            if obj.acquisitionService.hasSelectedProtocol()
                obj.view.setSelectedProtocol(obj.acquisitionService.getSelectedProtocol());
            end
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
            if ~obj.acquisitionService.hasSelectedProtocol()
                obj.view.setProtocolProperties(uiextras.jide.PropertyGridField.empty(0, 1));
                return;
            end
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
            if ~obj.acquisitionService.hasSelectedProtocol()
                obj.view.updateProtocolProperties(uiextras.jide.PropertyGridField.empty(0, 1));
                return;
            end
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
            if ~obj.acquisitionService.hasSelectedProtocol()
                obj.view.clearProtocolPreviewPanel();
                obj.protocolPreview = [];
                return;
            end
            obj.view.clearProtocolPreviewPanel();
            panel = obj.view.getProtocolPreviewPanel();
            try
                obj.protocolPreview = obj.acquisitionService.getProtocolPreview(panel);
            catch x
                obj.protocolPreview = [];
                obj.log.debug(x.message, x);
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
            try
                obj.acquisitionService.record();
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

        function onServiceChangedState(obj, ~, ~)
            obj.updateStateOfControls();

            state = obj.acquisitionService.getState();
            if state == symphonyui.core.ControllerState.STOPPED && ~isempty(obj.dataManagerPresenter)
                obj.dataManagerPresenter.updateCurrentEpochGroupBlocks();
            end
        end

        function updateStateOfControls(obj)
            import symphonyui.core.ControllerState;

            hasOpenFile = obj.documentationService.hasOpenFile();
            hasSource = hasOpenFile && ~isempty(obj.documentationService.getExperiment().sources);
            hasEpochGroup = hasOpenFile && ~isempty(obj.documentationService.getCurrentEpochGroup());
            hasAvailableProtocol = ~isempty(obj.acquisitionService.getAvailableProtocols());
            hasRig = obj.configurationService.hasRig();
            state = obj.acquisitionService.getState();
            isStopping = state == ControllerState.STOPPING;
            isStopped = state == ControllerState.STOPPED;
            [isValid, validationMessage] = obj.acquisitionService.validate();

            enableNewFile = ~hasOpenFile && isStopped;
            enableOpenFile = enableNewFile;
            enableCloseFile = hasOpenFile && isStopped;
            enableAddSource = hasOpenFile;
            enableBeginEpochGroup = hasSource;
            enableEndEpochGroup = hasEpochGroup;
            enableSelectProtocol = isStopped && hasAvailableProtocol;
            enableProtocolProperties = isStopped;
            enableViewOnly = isStopped && isValid;
            enableRecord = enableViewOnly && hasEpochGroup;
            enableStop = ~isStopping && ~isStopped;
            enableInitializeRig = isStopped;
            enableConfigureDeviceBackgrounds = isStopped && hasRig;

            if ~isValid
                status = validationMessage;
            elseif isStopped
                status = '';
            else
                status = char(state);
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
            obj.view.enableStop(enableStop);
            obj.view.enableInitializeRig(enableInitializeRig);
            obj.view.enableConfigureDeviceBackgrounds(enableConfigureDeviceBackgrounds);
            obj.view.setStatus(status);
        end

        function onViewSelectedInitializeRig(obj, ~, ~)
            obj.openInitializeRig();
        end

        function onServiceInitializedRig(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function onViewSelectedConfigureDeviceBackgrounds(obj, ~, ~)
            presenter = symphonyui.ui.presenters.DeviceBackgroundsPresenter(obj.configurationService);
            presenter.goWaitStop();
        end

        function onViewSelectedConfigureOptions(obj, ~, ~)
            presenter = symphonyui.ui.presenters.OptionsPresenter(obj.configurationService);
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
            message = { ...
                sprintf('%s', symphonyui.app.App.title), ...
                sprintf('Version %s', symphonyui.app.App.version), ...
                sprintf('%s', symphonyui.app.App.copyright)};
            obj.view.showMessage(message, 'About Symphony');
        end

    end

end
