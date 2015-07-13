classdef MainPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
        acquisitionService
        configurationService
        rigPresenter
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
            obj.updateViewState();
        end
        
        function onStopping(obj)
            obj.documentationService.close();
            obj.acquisitionService.close();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'NewFile', @obj.onViewSelectedNewFile);
            obj.addListener(v, 'OpenFile', @obj.onViewSelectedOpenFile);
            obj.addListener(v, 'CloseFile', @obj.onViewSelectedCloseFile);
            obj.addListener(v, 'Exit', @obj.onViewSelectedExit);
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'AddNoteToExperiment', @obj.onViewSelectedAddNoteToExperiment);
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'ShowDataManager', @obj.onViewSelectedShowDataManager);
            obj.addListener(v, 'SelectedProtocol', @obj.onViewSelectedProtocol);
            obj.addListener(v, 'SetProtocolProperty', @obj.onViewSetProtocolProperty);
            obj.addListener(v, 'ViewProtocol', @obj.onViewSelectedViewProtocol);
            obj.addListener(v, 'RecordProtocol', @obj.onViewSelectedRecordProtocol);
            obj.addListener(v, 'StopProtocol', @obj.onViewSelectedStopProtocol);
            obj.addListener(v, 'ShowProtocolPreview', @obj.onViewSelectedShowProtocolPreview);
            obj.addListener(v, 'ConfigureDeviceBackgrounds', @obj.onViewSelectedConfigureDeviceBackgrounds);
            obj.addListener(v, 'LoadRigConfiguration', @obj.onViewSelectedLoadRigConfiguration);
            obj.addListener(v, 'CreateRigConfiguration', @obj.onViewSelectedCreateRigConfiguration);
            obj.addListener(v, 'ConfigureOptions', @obj.onViewSelectedConfigureOptions);
            obj.addListener(v, 'ShowDocumentation', @obj.onViewSelectedShowDocumentation);
            obj.addListener(v, 'ShowUserGroup', @obj.onViewSelectedShowUserGroup);
            obj.addListener(v, 'ShowAbout', @obj.onViewSelectedShowAbout);
            
            d = obj.documentationService;
            obj.addListener(d, 'OpenedFile', @obj.onServiceOpenedFile);
            obj.addListener(d, 'ClosedFile', @obj.onServiceClosedFile);
            obj.addListener(d, 'AddedSource', @obj.onServiceAddedSource);
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);
            
            a = obj.acquisitionService;
            obj.addListener(a, 'SelectedProtocol', @obj.onServiceSelectedProtocol);
            obj.addListener(a, 'SetProtocolProperty', @obj.onServiceSetProtocolProperty);
            
            %obj.addListener(s, 'LoadedRigConfiguration', @obj.onServiceLoadedRigConfiguration);
        end
        
    end
    
    methods (Access = private)
        
        function onViewSelectedNewFile(obj, ~, ~)
            presenter = symphonyui.ui.presenters.NewFilePresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onViewSelectedOpenFile(obj, ~, ~)
            path = obj.view.showGetFile('File Location');
            if path == 0
                return;
            end
            obj.documentationService.openFile(path);
        end
        
        function onServiceOpenedFile(obj, ~, ~)
            obj.updateViewState();
            obj.showDataManager();
        end
        
        function onViewSelectedCloseFile(obj, ~, ~)
            obj.documentationService.closeFile();
        end
        
        function onServiceClosedFile(obj, ~, ~)
            obj.updateViewState();
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
            obj.updateViewState();
        end
        
        function onViewSelectedAddNoteToExperiment(obj, ~, ~)
            experiment = obj.documentationService.getCurrentExperiment();
            presenter = symphonyui.ui.presenters.AddNotePresenter(experiment, obj.app);
            presenter.goWaitStop();
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceBeganEpochGroup(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            obj.documentationService.endEpochGroup();
        end
        
        function onServiceEndedEpochGroup(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onViewSelectedShowDataManager(obj, ~, ~)
            obj.showDataManager();
        end
        
        function showDataManager(obj)
            if isempty(obj.dataManagerPresenter) || obj.dataManagerPresenter.isStopped
                obj.dataManagerPresenter = symphonyui.ui.presenters.DataManagerPresenter(obj.documentationService, obj.app);
                obj.dataManagerPresenter.hideOnViewSelectedClose = true;
                obj.dataManagerPresenter.go();
            else
                obj.dataManagerPresenter.show();
            end
        end
        
        function populateProtocolList(obj)
            protocols = obj.acquisitionService.getAvailableProtocols();
            
            names = cell(1, numel(protocols));
            for i = 1:numel(protocols)
                names{i} = protocols{i}.getDisplayName();
            end
            
            obj.view.setProtocolList(names, protocols);
            obj.view.setSelectedProtocol(obj.acquisitionService.getCurrentProtocol());
        end
        
        function onViewSelectedProtocol(obj, ~, ~)
            obj.acquisitionService.selectProtocol(obj.view.getSelectedProtocol());
        end
        
        function onServiceSelectedProtocol(obj, ~, ~)
            obj.view.setSelectedProtocol(obj.acquisitionService.getCurrentProtocol());
            obj.populateProtocolProperties();
            obj.updateViewState();
        end
        
        function onViewSetProtocolProperty(obj, ~, event)
            p = event.Property;
            obj.acquisitionService.setProtocolProperty(p.Name, p.Value);
        end
        
        function onServiceSetProtocolProperty(obj, ~, ~)
            obj.populateProtocolProperties(true);
            obj.updateViewState();
        end
        
        function onViewSelectedViewProtocol(obj, ~, ~)
            try
                obj.acquisitionService.viewProtocol();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedRecordProtocol(obj, ~, ~)
            try
                obj.acquisitionService.recordProtocol();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedStopProtocol(obj, ~, ~)
            try
                obj.acquisitionService.stopProtocol();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
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
                properties = uiextras.jide.PropertyGridField.GenerateFrom(obj.acquisitionService.getProtocolProperties());
            catch x
                properties = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            if update
                obj.view.updateProtocolProperties(properties);
            else
                obj.view.setProtocolProperties(properties);
            end
        end
        
        function updateViewState(obj)
            import symphonyui.core.RigState;
            
            %rig = obj.acquisitionService.getCurrentRig();
            
            hasOpenFile = obj.documentationService.hasOpenFile();
            hasSource = hasOpenFile && ~isempty(obj.documentationService.getCurrentExperiment().sources);
            hasCurrentEpochGroup = hasOpenFile && ~isempty(obj.documentationService.getCurrentEpochGroup());
            isRigStopped = true; %rig.state == RigState.STOPPED;
            isRigValid = true; %rig.isValid() == true;
            
            enableNewFile = ~hasOpenFile && isRigStopped && isRigValid;
            enableOpenFile = enableNewFile;
            enableCloseFile = hasOpenFile && isRigStopped;
            enableAddSource = hasOpenFile;
            enableAddNoteToExperiment = hasOpenFile;
            enableBeginEpochGroup = hasSource;
            enableEndEpochGroup = hasCurrentEpochGroup;
            enableShowDataManager = hasOpenFile;
            enableSelectProtocol = isRigStopped;
            enableProtocolProperties = isRigStopped;
            enableViewProtocol = false;
            enableRecordProtocol = false;
            enableStopProtocol = false;
            enableShowProtocolPreview = false;
            enableConfigureDeviceBackgrounds = isRigStopped;
            enableLoadRigConfiguration = ~hasOpenFile && isRigStopped;
            enableCreateRigConfiguration = ~hasOpenFile && isRigStopped;
            status = '';
            
            canRecord = hasCurrentEpochGroup;
%             switch rig.state
%                 case RigState.STOPPED
%                     enableViewProtocol = true;
%                     enableRecordProtocol = canRecord;
%                     enableShowProtocolPreview = true;
%                 case RigState.STOPPING
%                     status = 'Stopping...';
%                 case RigState.VIEWING
%                     enableStopProtocol = true;
%                     status = 'Viewing...';
%                 case RigState.RECORDING
%                     enableStopProtocol = true;
%                     status = 'Recording...';
%             end
            
            [valid, msg] = obj.acquisitionService.validate();
            if ~valid
                enableViewProtocol = false;
                enableRecordProtocol = false;
                enableStopProtocol = false;
                enableShowProtocolPreview = false;
                status = msg;
            end
            
            obj.view.enableNewFile(enableNewFile);
            obj.view.enableOpenFile(enableOpenFile);
            obj.view.enableCloseFile(enableCloseFile);
            obj.view.enableAddSource(enableAddSource);
            obj.view.enableAddNoteToExperiment(enableAddNoteToExperiment);
            obj.view.enableBeginEpochGroup(enableBeginEpochGroup);
            obj.view.enableEndEpochGroup(enableEndEpochGroup);
            obj.view.enableShowDataManager(enableShowDataManager);
            obj.view.enableSelectProtocol(enableSelectProtocol);
            obj.view.enableProtocolProperties(enableProtocolProperties);
            obj.view.enableViewProtocol(enableViewProtocol);
            obj.view.enableRecordProtocol(enableRecordProtocol);
            obj.view.enableStopProtocol(enableStopProtocol);
            obj.view.enableShowProtocolPreview(enableShowProtocolPreview);
            obj.view.enableConfigureDeviceBackgrounds(enableConfigureDeviceBackgrounds);
            obj.view.enableLoadRigConfiguration(enableLoadRigConfiguration);
            obj.view.enableCreateRigConfiguration(enableCreateRigConfiguration);
            obj.view.setStatus(status);
        end
        
        function onViewSelectedConfigureDeviceBackgrounds(obj, ~, ~)
            devices = obj.acquisitionService.getCurrentRig().devices;
            presenter = symphonyui.ui.presenters.DeviceBackgroundsPresenter(devices, obj.app);
            presenter.goWaitStop();
        end
        
        function onViewSelectedLoadRigConfiguration(obj, ~, ~)
            path = obj.view.showGetFile('Load Rig Configuration', '*.mat');
            if isempty(path)
                return;
            end
            try
                obj.acquisitionService.loadRigConfiguration(path);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceLoadedRigConfiguration(obj, ~, ~)
            obj.removeRigListeners();
            obj.addRigListeners();
            obj.updateViewState();
        end
        
        function onViewSelectedCreateRigConfiguration(obj, ~, ~)
            disp('Create rig config');
        end
        
%         function addRigListeners(obj)
%             rig = obj.acquisitionService.getCurrentRig();
%             manager = obj.eventManagers.rig;
%             manager.addListener(rig, 'Initialized', @obj.onRigInitialized);
%             manager.addListener(rig, 'Closed', @obj.onRigClosed);
%             manager.addListener(rig, 'state', 'PostSet', @obj.onRigSetState);
%         end
%         
%         function removeRigListeners(obj)
%             obj.eventManagers.rig.removeAllListeners();
%         end
        
        function onRigInitialized(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onRigClosed(obj, ~, ~)
            obj.updateViewState();
            
            if ~isempty(obj.rigPresenter)
                obj.rigPresenter.stop();
                obj.rigPresenter = [];
            end
        end
        
        function onRigSetState(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onViewSelectedConfigureOptions(obj, ~, ~)
            presenter = symphonyui.ui.presenters.OptionsPresenter(obj.app);
            presenter.goWaitStop();
        end
        
        function onViewSelectedShowRig(obj, ~, ~)
            obj.showRig();
        end
        
        function showRig(obj)
            if isempty(obj.rigPresenter) || obj.rigPresenter.isStopped
                rig = obj.acquisitionService.getCurrentRig();
                obj.rigPresenter = symphonyui.ui.presenters.RigPresenter(rig, obj.app);
                obj.rigPresenter.go();
            else
                obj.rigPresenter.show();
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

