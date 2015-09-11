classdef MainPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
        acquisitionService
        configurationService
        moduleService
        dataManagerPresenter
        protocolPreview
    end
    
    methods
        
        function obj = MainPresenter(documentationService, acquisitionService, configurationService, moduleService, app, view)            
            if nargin < 6
                view = symphonyui.ui.views.MainView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            
            obj.documentationService = documentationService;
            obj.acquisitionService = acquisitionService;
            obj.configurationService = configurationService;
            obj.moduleService = moduleService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.updateStateOfControls();
            obj.populateProtocolList();
            obj.populateProtocolProperties();
            obj.populateModuleList();
        end
        
        function onStopping(obj)
            obj.closeDataManager();
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
            obj.addListener(v, 'ConfigureHoldingLevels', @obj.onViewSelectedConfigureHoldingLevels);
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
        
        function onViewSelectedNewFile(obj, ~, ~)
            presenter = symphonyui.ui.presenters.NewFilePresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceCreatedFile(obj, ~, ~)
            obj.updateStateOfControls();
            obj.showDataManager();
        end
        
        function onViewSelectedOpenFile(obj, ~, ~)
            path = obj.view.showGetFile('File Location');
            if isempty(path)
                return;
            end
            try
                obj.documentationService.openFile(path);
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceOpenedFile(obj, ~, ~)
            obj.updateStateOfControls();
            obj.showDataManager();
        end
        
        function onViewSelectedCloseFile(obj, ~, ~)
            try
                obj.documentationService.closeFile();
            catch x
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
            presenter = symphonyui.ui.presenters.AddSourcePresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceAddedSource(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceBeganEpochGroup(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            try
                obj.documentationService.endEpochGroup();
            catch x
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
            if isempty(obj.dataManagerPresenter) || obj.dataManagerPresenter.isStopped
                presenter = symphonyui.ui.presenters.DataManagerPresenter(obj.documentationService, obj.app);
                presenter.go();
                obj.dataManagerPresenter = presenter;
            else
                obj.dataManagerPresenter.show();
            end
        end
        
        function closeDataManager(obj)
            if ~isempty(obj.dataManagerPresenter)
                obj.dataManagerPresenter.stop();
                obj.dataManagerPresenter = [];
            end
        end
        
        function populateProtocolList(obj)
            classNames = obj.acquisitionService.getAvailableProtocols();
            
            displayNames = cell(1, numel(classNames));
            for i = 1:numel(classNames)
                split = strsplit(classNames{i}, '.');
                displayNames{i} = symphonyui.core.util.humanize(split{end});
            end
            
            obj.view.setProtocolList(displayNames, classNames);
            obj.view.setSelectedProtocol(obj.acquisitionService.getSelectedProtocol());
        end
        
        function onViewSelectedProtocol(obj, ~, ~)
            try
                obj.acquisitionService.selectProtocol(obj.view.getSelectedProtocol());
            catch x
                obj.view.showError(x.message);
                return;
            end
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
            enableSelectProtocol = isStopped;
            enableProtocolProperties = isStopped;
            enableViewOnly = isStopped && isValid;
            enableRecord = enableViewOnly && hasEpochGroup;
            enableStop = ~isStopping && ~isStopped;
            enableInitializeRig = isStopped;
            enableConfigureHoldingLevels = isStopped && hasRig;
            
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
            obj.view.enableConfigureHoldingLevels(enableConfigureHoldingLevels);
            obj.view.setStatus(status);
        end
        
        function onViewSelectedInitializeRig(obj, ~, ~)
            presenter = symphonyui.ui.presenters.InitializeRigPresenter(obj.configurationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceInitializedRig(obj, ~, ~)
            obj.updateStateOfControls();
            obj.populateProtocolProperties();
            if ~obj.view.isProtocolPreviewMinimized()
                obj.populateProtocolPreview();
            end
        end
        
        function onViewSelectedConfigureHoldingLevels(obj, ~, ~)
            presenter = symphonyui.ui.presenters.HoldingLevelsPresenter(obj.configurationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onViewSelectedConfigureOptions(obj, ~, ~)
            disp('Selected configure options');
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
            obj.view.showWeb(obj.app.getDocumentationUrl);
        end
        
        function onViewSelectedShowUserGroup(obj, ~, ~)
            obj.view.showWeb(obj.app.getUserGroupUrl);
        end
        
        function onViewSelectedShowAbout(obj, ~, ~)
            message = { ...
                sprintf('Symphony Data Acquisition System'), ...
                sprintf('Version %s', obj.app.getVersion()), ...
                sprintf('%c %s Symphony-DAS', 169, datestr(now, 'YYYY'))};
            obj.view.showMessage(message, 'About Symphony');
        end
        
    end
    
end

