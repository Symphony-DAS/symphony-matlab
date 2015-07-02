classdef MainPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        acquisitionService
        rigPresenter
        experimentPresenter
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
                'experiment', symphonyui.ui.util.EventManager(), ...
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
            obj.addListener(v, 'NewExperiment', @obj.onViewSelectedNewExperiment);
            obj.addListener(v, 'OpenExperiment', @obj.onViewSelectedOpenExperiment);
            obj.addListener(v, 'CloseExperiment', @obj.onViewSelectedCloseExperiment);
            obj.addListener(v, 'Exit', @obj.onViewSelectedExit);
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'SelectedProtocol', @obj.onViewSelectedProtocol);
            obj.addListener(v, 'SetProtocolProperty', @obj.onViewSetProtocolProperty);
            obj.addListener(v, 'Record', @obj.onViewSelectedRecord);
            obj.addListener(v, 'Preview', @obj.onViewSelectedPreview);
            obj.addListener(v, 'Pause', @obj.onViewSelectedPause);
            obj.addListener(v, 'Stop', @obj.onViewSelectedStop);
            obj.addListener(v, 'ConfigureDeviceBackgrounds', @obj.onViewSelectedConfigureDeviceBackgrounds);
            obj.addListener(v, 'LoadRigConfiguration', @obj.onViewSelectedLoadRigConfiguration);
            obj.addListener(v, 'CreateRigConfiguration', @obj.onViewSelectedCreateRigConfiguration);
            obj.addListener(v, 'ConfigureOptions', @obj.onViewSelectedConfigureOptions);
            obj.addListener(v, 'ShowRig', @obj.onViewSelectedShowRig);
            obj.addListener(v, 'ShowProtocol', @obj.onViewSelectedShowProtocol);
            obj.addListener(v, 'ShowExperiment', @obj.onViewSelectedShowExperiment);
            obj.addListener(v, 'ShowDocumentation', @obj.onViewSelectedShowDocumentation);
            obj.addListener(v, 'ShowUserGroup', @obj.onViewSelectedShowUserGroup);
            obj.addListener(v, 'ShowAbout', @obj.onViewSelectedShowAbout);
            
            s = obj.acquisitionService;
            obj.addListener(s, 'OpenedExperiment', @obj.onServiceOpenedExperiment);
            obj.addListener(s, 'ClosedExperiment', @obj.onServiceClosedExperiment);
            obj.addListener(s, 'LoadedRigConfiguration', @obj.onServiceLoadedRigConfiguration);
            obj.addListener(s, 'SelectedProtocol', @obj.onServiceSelectedProtocol);
            
            obj.addRigListeners();
            obj.addProtocolListeners();
            if ~isempty(obj.acquisitionService.getCurrentExperiment())
                obj.addExperimentListeners();
            end
        end
        
    end
    
    methods (Access = private)
        
        function onViewSelectedNewExperiment(obj, ~, ~)
            presenter = symphonyui.ui.presenters.NewExperimentPresenter(obj.acquisitionService, obj.app);
            presenter.goWaitStop();
        end
        
        function onViewSelectedOpenExperiment(obj, ~, ~)
            disp('View Selected Open Experiment');
        end
        
        function onServiceOpenedExperiment(obj, ~, ~)   
            obj.addExperimentListeners();
            obj.updateViewState();
            obj.showExperiment();
        end
        
        function addExperimentListeners(obj)
            experiment = obj.acquisitionService.getCurrentExperiment();
            manager = obj.eventManagers.experiment;
            manager.addListener(experiment, 'AddedSource', @obj.onExperimentAddedSource);
            manager.addListener(experiment, 'BeganEpochGroup', @obj.onExperimentBeganEpochGroup);
            manager.addListener(experiment, 'EndedEpochGroup', @obj.onExperimentEndedEpochGroup);
        end
        
        function removeExperimentListeners(obj)
            obj.eventManagers.experiment.removeAllListeners();
        end
        
        function onViewSelectedCloseExperiment(obj, ~, ~)
            obj.acquisitionService.closeExperiment();
        end
        
        function onServiceClosedExperiment(obj, ~, ~)
            obj.removeExperimentListeners();
            obj.updateViewState();
            
            if ~isempty(obj.experimentPresenter)
                obj.experimentPresenter.stop();
                obj.experimentPresenter = [];
            end
        end
        
        function onViewSelectedExit(obj, ~, ~)
            obj.stop();
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            experiment = obj.acquisitionService.getCurrentExperiment();
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(experiment, obj.app);
            presenter.goWaitStop();
        end
        
        function onExperimentBeganEpochGroup(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            experiment = obj.acquisitionService.getCurrentExperiment();
            experiment.endEpochGroup();
        end
        
        function onExperimentEndedEpochGroup(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onViewSelectedAddSource(obj, ~, ~)
            experiment = obj.acquisitionService.getCurrentExperiment();
            presenter = symphonyui.ui.presenters.AddSourcePresenter(experiment, obj.app);
            presenter.goWaitStop();
        end
        
        function onExperimentAddedSource(obj, ~, ~)
            obj.updateViewState();
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
        
        function onViewSelectedRecord(obj, ~, ~)
            try
                obj.acquisitionService.record();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedPreview(obj, ~, ~)
            try
                obj.acquisitionService.preview();
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
            experiment = obj.acquisitionService.getCurrentExperiment();
            
            hasExperiment = ~isempty(experiment);
            hasSource = hasExperiment && ~isempty(experiment.sources);
            hasCurrentEpochGroup = hasExperiment && ~isempty(experiment.currentEpochGroup);
            isRigStopped = rig.state == RigState.STOPPED;
            isRigValid = rig.isValid() == true;
            
            enableNewExperiment = ~hasExperiment && isRigStopped && isRigValid;
            enableOpenExperiment = enableNewExperiment;
            enableCloseExperiment = hasExperiment && isRigStopped;
            enableBeginEpochGroup = hasSource;
            enableEndEpochGroup = hasCurrentEpochGroup;
            enableAddSource = hasExperiment;
            enableSelectProtocol = isRigStopped;
            enableProtocolProperties = isRigStopped;
            enableRecord = false;
            enablePreview = false;
            enablePause = false;
            enableStop = false;
            enableConfigureDeviceBackgrounds = isRigStopped;
            enableLoadRigConfiguration = ~hasExperiment && isRigStopped;
            enableCreateRigConfiguration = ~hasExperiment && isRigStopped;
            enableShowExperiment = hasExperiment;
            status = '';
            
            canRecord = hasCurrentEpochGroup;
            switch rig.state
                case RigState.STOPPED
                    enableRecord = canRecord;
                    enablePreview = true;
                case RigState.STOPPING
                    status = 'Stopping...';
                case RigState.PAUSED
                    enableRecord = canRecord;
                    enablePreview = true;
                    enableStop = true;
                    status = 'Paused';
                case RigState.PAUSING
                    enableStop = true;
                    status = 'Pausing...';
                case RigState.PREVIEWING
                    enablePause = true;
                    enableStop = true;
                    status = 'Previewing...';
                case RigState.RECORDING
                    enablePause = true;
                    enableStop = true;
                    status = 'Recording...';
            end
            
            [valid, msg] = obj.acquisitionService.validate();
            if ~valid
                enableRecord = false;
                enablePreview = false;
                enablePause = false;
                enableStop = false;
                status = msg;
            end
            
            obj.view.enableNewExperiment(enableNewExperiment);
            obj.view.enableOpenExperiment(enableOpenExperiment);
            obj.view.enableCloseExperiment(enableCloseExperiment);
            obj.view.enableBeginEpochGroup(enableBeginEpochGroup);
            obj.view.enableEndEpochGroup(enableEndEpochGroup);
            obj.view.enableAddSource(enableAddSource);
            obj.view.enableSelectProtocol(enableSelectProtocol);
            obj.view.enableProtocolProperties(enableProtocolProperties);
            obj.view.enableRecord(enableRecord);
            obj.view.enablePreview(enablePreview);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.enableConfigureDeviceBackgrounds(enableConfigureDeviceBackgrounds);
            obj.view.enableLoadRigConfiguration(enableLoadRigConfiguration);
            obj.view.enableCreateRigConfiguration(enableCreateRigConfiguration);
            obj.view.enableShowExperiment(enableShowExperiment);
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
        
        function onViewSelectedShowProtocol(obj, ~, ~)
            obj.showProtocol();
        end
        
        function showProtocol(obj)
            disp('Show protocol');
        end
        
        function onViewSelectedShowExperiment(obj, ~, ~)
            obj.showExperiment();
        end
        
        function showExperiment(obj)
            if isempty(obj.experimentPresenter) || obj.experimentPresenter.isStopped
                experiment = obj.acquisitionService.getCurrentExperiment();
                obj.experimentPresenter = symphonyui.ui.presenters.ExperimentPresenter(experiment, obj.app);
                obj.experimentPresenter.hideOnViewSelectedClose = true;
                obj.experimentPresenter.go();
            else
                obj.experimentPresenter.show();
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

