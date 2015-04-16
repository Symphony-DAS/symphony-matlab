classdef MainPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        acquisitionService
        experimentPresenter
        protocolIdToName
        eventManagers
    end
    
    methods
        
        function obj = MainPresenter(acquisitionService, app, view)            
            if nargin < 3
                view = symphonyui.ui.views.MainView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view); 
            obj.acquisitionService = acquisitionService;
            obj.protocolIdToName = symphonyui.ui.util.BiMap();
            obj.eventManagers = struct( ...
                'experiment', symphonyui.ui.util.EventManager(), ...
                'rig', symphonyui.ui.util.EventManager(), ...
                'protocol', symphonyui.ui.util.EventManager());
        end
        
        function showRigLoader(obj)
            presenter = symphonyui.ui.presenters.LoadRigPresenter(obj.acquisitionService, obj.app);
            presenter.goWaitStop();
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.populateProtocolList();
            obj.selectCurrentProtocol();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'NewExperiment', @obj.onViewSelectedNewExperiment);
            obj.addListener(v, 'OpenExperiment', @obj.onViewSelectedOpenExperiment);
            obj.addListener(v, 'CloseExperiment', @obj.onViewSelectedCloseExperiment);
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'ViewExperiment', @obj.onViewSelectedViewExperiment);
            obj.addListener(v, 'SelectedProtocol', @obj.onViewSelectedProtocol);
            obj.addListener(v, 'SetProtocolProperty', @obj.onViewSetProtocolProperty);
            obj.addListener(v, 'Record', @obj.onViewSelectedRecord);
            obj.addListener(v, 'Preview', @obj.onViewSelectedPreview);
            obj.addListener(v, 'Pause', @obj.onViewSelectedPause);
            obj.addListener(v, 'Stop', @obj.onViewSelectedStop);
            obj.addListener(v, 'LoadRig', @obj.onViewSelectedLoadRig);
            obj.addListener(v, 'Settings', @obj.onViewSelectedSettings);
            obj.addListener(v, 'Documentation', @obj.onViewSelectedDocumentation);
            obj.addListener(v, 'UserGroup', @obj.onViewSelectedUserGroup);
            obj.addListener(v, 'AboutSymphony', @obj.onViewSelectedAboutSymphony);
            obj.addListener(v, 'Exit', @obj.onViewSelectedExit);
            
            s = obj.acquisitionService;
            obj.addListener(s, 'OpenedExperiment', @obj.onServiceOpenedExperiment);
            obj.addListener(s, 'ClosedExperiment', @obj.onServiceClosedExperiment);
            obj.addListener(s, 'LoadedRig', @obj.onServiceLoadedRig);
            obj.addListener(s, 'SelectedProtocol', @obj.onServiceSelectedProtocol);
            
            obj.addRigListeners();
            obj.addProtocolListeners();
            if obj.acquisitionService.hasCurrentExperiment()
                obj.addExperimentListeners();
            end
        end
        
        function onViewSelectedClose(obj, ~, ~)
            obj.exit();
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
            
            experiment = obj.acquisitionService.getCurrentExperiment();
            obj.experimentPresenter = symphonyui.ui.presenters.ExperimentPresenter(experiment, obj.app);
            obj.experimentPresenter.go();
        end
        
        function onViewSelectedCloseExperiment(obj, ~, ~)
            obj.acquisitionService.closeExperiment();
        end
        
        function onServiceClosedExperiment(obj, ~, ~)
            obj.removeExperimentListeners();
            obj.updateViewState();
            
            obj.experimentPresenter.stop();
            obj.experimentPresenter = [];
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
        
        function onViewSelectedAddSource(obj, ~, ~)
            experiment = obj.acquisitionService.getCurrentExperiment();
            presenter = symphonyui.ui.presenters.AddSourcePresenter(experiment, obj.app);
            presenter.goWaitStop();
        end
        
        function onExperimentAddedSource(obj, ~, ~)
            obj.updateViewState();
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
        
        function onViewSelectedViewExperiment(obj, ~, ~)
            obj.experimentPresenter.show();
        end
        
        function onViewSelectedLoadRig(obj, ~, ~)
            obj.showRigLoader();
        end
        
        function onServiceLoadedRig(obj, ~, ~)
            obj.removeRigListeners();
            obj.addRigListeners();
            obj.updateViewState();
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
        end
        
        function onRigSetState(obj, ~, ~)
            obj.updateViewState();
        end
        
        function populateProtocolList(obj)
            obj.protocolIdToName.clear();
            
            ids = obj.acquisitionService.getAvailableProtocolIds();
            for i = 1:numel(ids)
                split = strsplit(ids{i}, '.');
                name = symphonyui.ui.util.humanize(split{end});
                obj.protocolIdToName.put(ids{i}, name);
            end
            
            obj.view.setProtocolList(obj.protocolIdToName.values);
        end
        
        function onViewSelectedProtocol(obj, ~, ~)
            id = obj.protocolIdToName.getKey(obj.view.getSelectedProtocol());
            try
                obj.acquisitionService.selectProtocol(id);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceSelectedProtocol(obj, ~, ~)
            obj.removeProtocolListeners();
            obj.addProtocolListeners();
            obj.selectCurrentProtocol();
        end
        
        function selectCurrentProtocol(obj)
            name = obj.protocolIdToName.get(obj.acquisitionService.getCurrentProtocolId());
            obj.view.setSelectedProtocol(name);
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
            
            experiment = obj.acquisitionService.getCurrentExperiment();
            rig = obj.acquisitionService.getCurrentRig();
            
            hasExperiment = ~isempty(experiment);
            hasSource = hasExperiment && ~isempty(experiment.sources);
            hasCurrentEpochGroup = hasExperiment && ~isempty(experiment.currentEpochGroup);
            isStopped = rig.state == RigState.STOPPED;
            
            enableNewExperiment = ~hasExperiment && isStopped && rig.isValid();
            enableOpenExperiment = enableNewExperiment;
            enableCloseExperiment = hasExperiment && isStopped;
            enableAddSource = hasExperiment;
            enableBeginEpochGroup = hasSource;
            enableEndEpochGroup = hasCurrentEpochGroup;
            enableViewExperiment = hasExperiment;
            enableLoadRig = ~hasExperiment && isStopped;
            enableSettings = ~hasExperiment && isStopped;
            enableSelectProtocol = isStopped;
            enableProtocolProperties = isStopped;
            enableRecord = false;
            enablePreview = false;
            enablePause = false;
            enableStop = false;
            enableProgressIndicator = false;
            enableWarning = false;
            warning = '';
            status = '';
            
            canRecord = hasCurrentEpochGroup;
            switch rig.state
                case RigState.STOPPED
                    enableRecord = canRecord;
                    enablePreview = true;
                case RigState.STOPPING
                    enableProgressIndicator = true;
                    status = 'Stopping...';
                case RigState.PAUSED
                    enableRecord = canRecord;
                    enablePreview = true;
                    enableStop = true;
                    status = 'Paused';
                case RigState.PAUSING
                    enableStop = true;
                    enableProgressIndicator = true;
                    status = 'Pausing...';
                case RigState.PREVIEWING
                    enablePause = true;
                    enableStop = true;
                    enableProgressIndicator = true;
                    status = 'Previewing...';
                case RigState.RECORDING
                    enablePause = true;
                    enableStop = true;
                    enableProgressIndicator = true;
                    status = 'Recording...';
            end
            
            [valid, msg] = obj.acquisitionService.validate();
            if ~valid
                enableRecord = false;
                enablePreview = false;
                enablePause = false;
                enableStop = false;
                enableWarning = true;
                warning = msg;
            end
            
            obj.view.enableNewExperiment(enableNewExperiment);
            obj.view.enableOpenExperiment(enableOpenExperiment);
            obj.view.enableAddSource(enableAddSource);
            obj.view.enableCloseExperiment(enableCloseExperiment);
            obj.view.enableBeginEpochGroup(enableBeginEpochGroup);
            obj.view.enableEndEpochGroup(enableEndEpochGroup);
            obj.view.enableViewExperiment(enableViewExperiment);
            obj.view.enableLoadRig(enableLoadRig);
            obj.view.enableSettings(enableSettings);
            obj.view.enableSelectProtocol(enableSelectProtocol);
            obj.view.enableProtocolProperties(enableProtocolProperties);
            obj.view.enableRecord(enableRecord);
            obj.view.enablePreview(enablePreview);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.enableProgressIndicator(enableProgressIndicator);
            obj.view.enableWarning(enableWarning);
            obj.view.setWarning(warning);
            obj.view.setStatus(status);
        end
        
        function onViewSelectedSettings(obj, ~, ~)
            presenter = symphonyui.ui.presenters.SettingsPresenter(obj.app);
            presenter.goWaitStop();
        end
        
        function onViewSelectedDocumentation(obj, ~, ~)
            obj.view.showWeb(obj.app.getDocumentationUrl);
        end
        
        function onViewSelectedUserGroup(obj, ~, ~)
            obj.view.showWeb(obj.app.getUserGroupUrl);
        end
        
        function onViewSelectedAboutSymphony(obj, ~, ~)
            message = { ...
                sprintf('Symphony Data Acquisition System'), ...
                sprintf('Version %s', obj.app.getVersion()), ...
                sprintf('%c %s Symphony-DAS', 169, datestr(now, 'YYYY'))};
            obj.view.showMessage(message, 'About Symphony');
        end
        
        function onViewSelectedExit(obj, ~, ~)
            obj.exit();
        end
        
        function exit(obj)
            delete(obj.acquisitionService);
            obj.stop();
        end
        
    end
    
end

