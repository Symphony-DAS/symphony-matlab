classdef MainPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        acquisitionService
        rigPresenter
        dataManagerPresenter
        eventManagers
    end
    
    methods
        
        function obj = MainPresenter(acquisitionService, app, view)            
            if nargin < 3
                view = symphonyui.ui.views.MainView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view); 
            obj.acquisitionService = acquisitionService;
            obj.eventManagers = struct( ...
                'persistor', symphonyui.ui.util.EventManager(), ...
                'rig', symphonyui.ui.util.EventManager(), ...
                'protocol', symphonyui.ui.util.EventManager());
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.populateProtocolList();
            obj.populateProtocolProperties();
            obj.updateViewState();
        end
        
        function onStopping(obj)
            delete(obj.acquisitionService);
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
            
            s = obj.acquisitionService;
            obj.addListener(s, 'OpenedFile', @obj.onServiceOpenedFile);
            obj.addListener(s, 'ClosedFile', @obj.onServiceClosedFile);
            obj.addListener(s, 'LoadedRigConfiguration', @obj.onServiceLoadedRigConfiguration);
            obj.addListener(s, 'SelectedProtocol', @obj.onServiceSelectedProtocol);
            
            obj.addRigListeners();
            obj.addProtocolListeners();
            if ~isempty(obj.acquisitionService.getCurrentPersistor())
                obj.addPersistorListeners();
            end
        end
        
    end
    
    methods (Access = private)
        
        function onViewSelectedNewFile(obj, ~, ~)
            presenter = symphonyui.ui.presenters.NewFilePresenter(obj.acquisitionService, obj.app);
            presenter.goWaitStop();
        end
        
        function onViewSelectedOpenFile(obj, ~, ~)
            [filename, path] = uigetfile('*.h5');
            if filename == 0
                return;
            end
            obj.acquisitionService.openFile(fullfile(path, filename));
        end
        
        function onServiceOpenedFile(obj, ~, ~)   
            obj.addPersistorListeners();
            obj.updateViewState();
            obj.showDataManager();
        end
        
        function addPersistorListeners(obj)
            persistor = obj.acquisitionService.getCurrentPersistor();
            manager = obj.eventManagers.persistor;
            manager.addListener(persistor, 'AddedSource', @obj.onPersistorAddedSource);
            manager.addListener(persistor, 'BeganEpochGroup', @obj.onPersistorBeganEpochGroup);
            manager.addListener(persistor, 'EndedEpochGroup', @obj.onPersistorEndedEpochGroup);
        end
        
        function removePersistorListeners(obj)
            obj.eventManagers.persistor.removeAllListeners();
        end
        
        function onViewSelectedCloseFile(obj, ~, ~)
            obj.acquisitionService.closeFile();
        end
        
        function onServiceClosedFile(obj, ~, ~)
            obj.removePersistorListeners();
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
            persistor = obj.acquisitionService.getCurrentPersistor();
            presenter = symphonyui.ui.presenters.AddSourcePresenter(persistor, obj.app);
            presenter.goWaitStop();
        end
        
        function onPersistorAddedSource(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onViewSelectedAddNoteToExperiment(obj, ~, ~)
            persistor = obj.acquisitionService.getCurrentPersistor();
            presenter = symphonyui.ui.presenters.AddNotePresenter(persistor.experiment, obj.app);
            presenter.goWaitStop();
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            persistor = obj.acquisitionService.getCurrentPersistor();
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(persistor, obj.app);
            presenter.goWaitStop();
        end
        
        function onPersistorBeganEpochGroup(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            persistor = obj.acquisitionService.getCurrentPersistor();
            persistor.endEpochGroup();
        end
        
        function onPersistorEndedEpochGroup(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onViewSelectedShowDataManager(obj, ~, ~)
            obj.showDataManager();
        end
        
        function showDataManager(obj)
            if isempty(obj.dataManagerPresenter) || obj.dataManagerPresenter.isStopped
                persistor = obj.acquisitionService.getCurrentPersistor();
                obj.dataManagerPresenter = symphonyui.ui.presenters.DataManagerPresenter(persistor, obj.app);
                obj.dataManagerPresenter.hideOnViewSelectedClose = true;
                obj.dataManagerPresenter.go();
            else
                obj.dataManagerPresenter.show();
            end
        end
        
        function populateProtocolList(obj)
            ids = obj.acquisitionService.getAvailableProtocolIds();
            names = cell(1, numel(ids));
            for i = 1:numel(ids)
                split = strsplit(ids{i}, '.');
                names{i} = symphonyui.ui.util.humanize(split{end});
            end
            values = ids;
            obj.view.setProtocolList(names, values);
            obj.view.setSelectedProtocol(obj.acquisitionService.getCurrentProtocolId());
        end
        
        function onViewSelectedProtocol(obj, ~, ~)
            try
                obj.acquisitionService.selectProtocol(obj.view.getSelectedProtocol());
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceSelectedProtocol(obj, ~, ~)
            obj.removeProtocolListeners();
            obj.addProtocolListeners();
            obj.view.setSelectedProtocol(obj.acquisitionService.getCurrentProtocolId());
            obj.populateProtocolProperties();
            obj.updateViewState();
        end
        
        function addProtocolListeners(obj)
            protocol = obj.acquisitionService.getCurrentProtocol();
            manager = obj.eventManagers.protocol;
            manager.addListener(protocol, 'SetProperty', @obj.onProtocolSetProperty);
        end
        
        function removeProtocolListeners(obj)
            obj.eventManagers.protocol.removeAllListeners();
        end
        
        function onViewSetProtocolProperty(obj, ~, event)
            property = event.Property;
            protocol = obj.acquisitionService.getCurrentProtocol();
            protocol.(property.Name) = property.Value;
        end
        
        function onProtocolSetProperty(obj, ~, ~)
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
            protocol = obj.acquisitionService.getCurrentProtocol();
            try
                properties = uiextras.jide.PropertyGridField.GenerateFrom(protocol);
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
            
            rig = obj.acquisitionService.getCurrentRig();
            persistor = obj.acquisitionService.getCurrentPersistor();
            
            hasPersistor = ~isempty(persistor);
            hasSource = hasPersistor && ~isempty(persistor.experiment.sources);
            hasCurrentEpochGroup = hasPersistor && ~isempty(persistor.currentEpochGroup);
            isRigStopped = rig.state == RigState.STOPPED;
            isRigValid = rig.isValid() == true;
            
            enableNewFile = ~hasPersistor && isRigStopped && isRigValid;
            enableOpenFile = enableNewFile;
            enableCloseFile = hasPersistor && isRigStopped;
            enableAddSource = hasPersistor;
            enableAddNoteToExperiment = hasPersistor;
            enableBeginEpochGroup = hasSource;
            enableEndEpochGroup = hasCurrentEpochGroup;
            enableShowDataManager = hasPersistor;
            enableSelectProtocol = isRigStopped;
            enableProtocolProperties = isRigStopped;
            enableViewProtocol = false;
            enableRecordProtocol = false;
            enableStopProtocol = false;
            enableShowProtocolPreview = false;
            enableConfigureDeviceBackgrounds = isRigStopped;
            enableLoadRigConfiguration = ~hasPersistor && isRigStopped;
            enableCreateRigConfiguration = ~hasPersistor && isRigStopped;
            status = '';
            
            canRecord = hasCurrentEpochGroup;
            switch rig.state
                case RigState.STOPPED
                    enableViewProtocol = true;
                    enableRecordProtocol = canRecord;
                    enableShowProtocolPreview = true;
                case RigState.STOPPING
                    status = 'Stopping...';
                case RigState.VIEWING
                    enableStopProtocol = true;
                    status = 'Viewing...';
                case RigState.RECORDING
                    enableStopProtocol = true;
                    status = 'Recording...';
            end
            
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
        
        function addRigListeners(obj)
            rig = obj.acquisitionService.getCurrentRig();
            manager = obj.eventManagers.rig;
            manager.addListener(rig, 'Initialized', @obj.onRigInitialized);
            manager.addListener(rig, 'Closed', @obj.onRigClosed);
            manager.addListener(rig, 'state', 'PostSet', @obj.onRigSetState);
        end
        
        function removeRigListeners(obj)
            obj.eventManagers.rig.removeAllListeners();
        end
        
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

