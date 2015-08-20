classdef MainPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
        acquisitionService
        configurationService
        dataManagerPresenter
    end
    
    methods
        
        function obj = MainPresenter(documentationService, acquisitionService, configurationService, app, view)            
            if nargin < 5
                view = symphonyui.ui.views.MainView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            
            obj.documentationService = documentationService;
            obj.acquisitionService = acquisitionService;
            obj.configurationService = configurationService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.populateProtocolList();
            obj.populateProtocolProperties();
            obj.updateStateOfControls();
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
            obj.addListener(v, 'ShowDataManager', @obj.onViewSelectedShowDataManager);
            obj.addListener(v, 'SelectedProtocol', @obj.onViewSelectedProtocol);
            obj.addListener(v, 'SetProtocolProperty', @obj.onViewSetProtocolProperty);
            obj.addListener(v, 'ViewOnly', @obj.onViewSelectedViewOnly);
            obj.addListener(v, 'Record', @obj.onViewSelectedRecord);
            obj.addListener(v, 'Stop', @obj.onViewSelectedStop);
            obj.addListener(v, 'ShowProtocolPreview', @obj.onViewSelectedShowProtocolPreview);
            obj.addListener(v, 'InitializeRig', @obj.onViewSelectedInitializeRig);
            obj.addListener(v, 'ConfigureDeviceBackgrounds', @obj.onViewSelectedConfigureDeviceBackgrounds);
            obj.addListener(v, 'ConfigureOptions', @obj.onViewSelectedConfigureOptions);
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
            if ~isempty(obj.dataManagerPresenter)
                obj.dataManagerPresenter.stop();
                obj.dataManagerPresenter = [];
            end
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
        
        function onViewSelectedShowDataManager(obj, ~, ~)
            obj.showDataManager();
        end
        
        function showDataManager(obj)
            if isempty(obj.dataManagerPresenter) || obj.dataManagerPresenter.isStopped
                obj.dataManagerPresenter = symphonyui.ui.presenters.DataManagerPresenter(obj.documentationService, obj.app);
                obj.dataManagerPresenter.go();
            else
                obj.dataManagerPresenter.show();
            end
        end
        
        function populateProtocolList(obj)
            [classNames, displayNames] = obj.acquisitionService.getAvailableProtocolNames();
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
            obj.populateProtocolProperties();
            obj.updateStateOfControls();
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
            obj.populateProtocolProperties(true);
            obj.updateStateOfControls();
        end
        
        function onViewSelectedViewOnly(obj, ~, ~)
            try
                obj.acquisitionService.viewOnly();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedRecord(obj, ~, ~)
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
        
        function onViewSelectedShowProtocolPreview(obj, ~, ~)
            obj.showProtocolPreview();
        end
        
        function showProtocolPreview(obj)
            disp('Show protocol preview');
        end
        
        function populateProtocolProperties(obj, update)
            if nargin < 2
                update = false;
            end
            try
                fields = symphonyui.ui.util.desc2field(obj.acquisitionService.getProtocolPropertyDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            if update
                obj.view.updateProtocolProperties(fields);
            else
                obj.view.setProtocolProperties(fields);
            end
        end
        
        function updateStateOfControls(obj)
            import symphonyui.core.ControllerState;
            
            hasOpenFile = obj.documentationService.hasOpenFile();
            hasSource = hasOpenFile && ~isempty(obj.documentationService.getExperiment().sources);
            hasEpochGroup = hasOpenFile && ~isempty(obj.documentationService.getCurrentEpochGroup());       
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
            enableShowDataManager = hasOpenFile;
            enableSelectProtocol = isStopped;
            enableProtocolProperties = isStopped;
            enableViewOnly = isStopped && isValid;
            enableRecord = enableViewOnly && hasEpochGroup;
            enableStop = ~isStopping && ~isStopped;
            enableShowProtocolPreview = enableViewOnly;
            enableInitializeRig = ~hasOpenFile && isStopped;
            enableConfigureDeviceBackgrounds = isStopped;
            
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
            obj.view.enableShowDataManager(enableShowDataManager);
            obj.view.enableSelectProtocol(enableSelectProtocol);
            obj.view.enableProtocolProperties(enableProtocolProperties);
            obj.view.enableViewOnly(enableViewOnly);
            obj.view.enableRecord(enableRecord);
            obj.view.enableStop(enableStop);
            obj.view.enableShowProtocolPreview(enableShowProtocolPreview);
            obj.view.enableInitializeRig(enableInitializeRig);
            obj.view.enableConfigureDeviceBackgrounds(enableConfigureDeviceBackgrounds);
            obj.view.setStatus(status);
        end
        
        function onViewSelectedInitializeRig(obj, ~, ~)
            presenter = symphonyui.ui.presenters.InitializeRigPresenter(obj.configurationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceInitializedRig(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function onViewSelectedConfigureDeviceBackgrounds(obj, ~, ~)
            disp('Selected configure device backgrounds');
        end
        
        function onViewSelectedConfigureOptions(obj, ~, ~)
            disp('Selected configure options');
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

