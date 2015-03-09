classdef MainPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        mainService
        listeners
    end
    
    methods
        
        function obj = MainPresenter(mainService, app, view)            
            if nargin < 3
                view = symphonyui.ui.views.MainView();
            end
            
            obj = obj@symphonyui.ui.Presenter(app, view);            
            obj.addListener(view, 'NewExperiment', @obj.onViewSelectedNewExperiment);
            obj.addListener(view, 'CloseExperiment', @obj.onViewSelectedCloseExperiment);
            obj.addListener(view, 'ViewExperiment', @obj.onViewSelectedViewExperiment);
            obj.addListener(view, 'AddNote', @obj.onViewSelectedAddNote);
            obj.addListener(view, 'SelectedProtocol', @obj.onViewSelectedProtocol);
            obj.addListener(view, 'ChangedProtocolParameters', @obj.onViewChangedProtocolParameters);
            obj.addListener(view, 'Record', @obj.onViewSelectedRecord);
            obj.addListener(view, 'Preview', @obj.onViewSelectedPreview);
            obj.addListener(view, 'Pause', @obj.onViewSelectedPause);
            obj.addListener(view, 'Stop', @obj.onViewSelectedStop);
            obj.addListener(view, 'SelectRig', @obj.onViewSelectedSelectRig);
            obj.addListener(view, 'Settings', @obj.onViewSelectedSettings);
            obj.addListener(view, 'Documentation', @obj.onViewSelectedDocumentation);
            obj.addListener(view, 'UserGroup', @obj.onViewSelectedUserGroup);
            obj.addListener(view, 'AboutSymphony', @obj.onViewSelectedAboutSymphony);
            obj.addListener(view, 'Exit', @obj.onViewSelectedExit);
            
            obj.mainService = mainService;
            obj.addListener(mainService, 'OpenedExperiment', @obj.onServiceOpenedExperiment);
            obj.addListener(mainService, 'ClosedExperiment', @obj.onServiceClosedExperiment);
            obj.addListener(mainService, 'SelectedRig', @obj.onServiceSelectedRig);
            obj.addListener(mainService, 'ChangedAvailableProtocols', @obj.onServiceChangedAvailableProtocols);
            obj.addListener(mainService, 'SelectedProtocol', @obj.onServiceSelectedProtocol);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.ui.Presenter(obj);
            
            %obj.view.loadPosition();
            obj.view.setTitle(obj.app.displayName);
            obj.view.setProtocolList(obj.mainService.getAvailableProtocolIds());
            obj.view.setSelectedProtocol(obj.mainService.getCurrentProtocol().id);
            
            obj.addRigListeners();
            obj.addProtocolListeners();
            
            obj.updateViewProtocolParameters();
            obj.updateViewState();
        end
        
        function onViewClosing(obj, ~, ~)
            onViewClosing@symphonyui.ui.Presenter(obj);
            %obj.view.savePosition();
            delete(obj.mainService);            
        end
        
    end
    
    methods (Access = private)
        
        function onViewSelectedNewExperiment(obj, ~, ~)
            view = symphonyui.ui.views.NewExperimentView(obj.view);
            presenter = symphonyui.ui.presenters.NewExperimentPresenter(obj.mainService, obj.app, view);
            presenter.view.showDialog();
        end
        
        function onServiceOpenedExperiment(obj, ~, ~)
            obj.addExperimentListeners();
            obj.updateViewState();
        end
        
        function onViewSelectedCloseExperiment(obj, ~, ~)
            obj.mainService.closeExperiment();
        end
        
        function onServiceClosedExperiment(obj, ~, ~)
            obj.removeExperimentListeners();
            obj.updateViewState();
        end
        
        function addExperimentListeners(obj)
            experiment = obj.mainService.getCurrentExperiment();
            obj.listeners.experiment.close = [];
        end
        
        function removeExperimentListeners(obj)
            fields = fieldnames(obj.listeners.experiment);
            for i = 1:numel(fields)
                obj.removeListener(obj.listeners.experiment.(fields{i}));
            end
        end
        
        function onViewSelectedViewExperiment(obj, ~, ~)
            experiment = obj.mainService.getCurrentExperiment();
            view = symphonyui.ui.views.ExperimentView(obj.view);
            presenter = symphonyui.ui.presenters.ExperimentPresenter(experiment, obj.app, view);
            presenter.view.show();
        end
        
        function onViewSelectedAddNote(obj, ~, ~)
            disp('View Selected Add Note');
        end
        
        function onViewSelectedSelectRig(obj, ~, ~)
            view = symphonyui.ui.views.SelectRigView(obj.view);
            p = symphonyui.ui.presenters.SelectRigPresenter(obj.mainService, obj.app, view);
            p.view.showDialog();
        end
        
        function onServiceSelectedRig(obj, ~, ~)
            obj.removeRigListeners();
            obj.addRigListeners();
        end
        
        function addRigListeners(obj)
            rig = obj.mainService.getCurrentRig();
            obj.listeners.rig.initialized = obj.addListener(rig, 'Initialized', @obj.onRigInitialized);
            obj.listeners.rig.closed = obj.addListener(rig, 'Closed', @obj.onRigClosed);
            obj.listeners.rig.changedState = obj.addListener(rig, 'state', 'PostSet', @obj.onRigSetState);
        end
        
        function removeRigListeners(obj)
            fields = fieldnames(obj.listeners.rig);
            for i = 1:numel(fields)
                obj.removeListener(obj.listeners.rig.(fields{i}));
            end
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
        
        function onServiceChangedAvailableProtocols(obj, ~, ~)
            obj.view.setProtocolList(obj.mainService.getAvailableProtocolIds());
        end
        
        function onViewSelectedProtocol(obj, ~, ~)
            try
                obj.mainService.selectProtocol(obj.view.getSelectedProtocol());
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceSelectedProtocol(obj, ~, ~)
            obj.removeProtocolListeners();
            obj.addProtocolListeners();
            obj.view.setSelectedProtocol(obj.mainService.getCurrentProtocol().id);
            obj.updateViewProtocolParameters();
            obj.updateViewState();
        end
        
        function addProtocolListeners(obj)
            protocol = obj.mainService.getCurrentProtocol();
            obj.listeners.protocol.changedParameters = obj.addListener(protocol, 'ChangedParameters', @obj.onProtocolChangedParameters);
        end
        
        function removeProtocolListeners(obj)
            fields = fieldnames(obj.listeners.protocol);
            for i = 1:numel(fields)
                obj.removeListener(obj.listeners.protocol.(fields{i}));
            end
        end
        
        function onViewChangedProtocolParameters(obj, ~, ~)
            parameters = obj.view.getProtocolParameters();
            protocol = obj.mainService.getCurrentProtocol();
            protocol.setParameters(parameters);
        end
        
        function onProtocolChangedParameters(obj, ~, ~)
            obj.updateViewProtocolParameters(false);
            obj.updateViewState();
        end
        
        function onViewSelectedRecord(obj, ~, ~)
            try
                obj.mainService.record();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedPreview(obj, ~, ~)
            try
                obj.mainService.preview();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedPause(obj, ~, ~)
            try
                obj.mainService.pause();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedStop(obj, ~, ~)
            try
                obj.mainService.stop();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function updateViewProtocolParameters(obj, clear)
            if nargin < 2
                clear = true;
            end
            parameters = obj.mainService.getCurrentProtocol().getParameters();
            i = ~arrayfun(@(e)any(strcmp(e.name, {'displayName', 'version'})), parameters);
            if clear
                obj.view.setProtocolParameters(parameters(i));
            else
                obj.view.updateProtocolParameters(parameters(i));
            end
        end
        
        function updateViewState(obj)
            import symphonyui.core.RigState;
            
            hasExperiment = obj.mainService.hasCurrentExperiment();
            isRigValid = obj.mainService.getCurrentRig().isValid();
            isStopped = obj.mainService.getCurrentRig().state == RigState.STOPPED;
            
            enableNewExperiment = ~hasExperiment && isStopped && isRigValid;
            enableCloseExperiment = hasExperiment && isStopped;
            enableViewExperiment = hasExperiment;
            enableAddNote = hasExperiment;
            enableSelectRig = ~hasExperiment && isStopped;
            enableSettings = ~hasExperiment && isStopped;
            enableSelectProtocol = isStopped;
            enableProtocolParameters = isStopped;
            enableRecord = false;
            enablePreview = false;
            enablePause = false;
            enableStop = false;
            status = 'Unknown';
            
            switch obj.mainService.getCurrentRig().state
                case RigState.STOPPED
                    enableRecord = hasExperiment;
                    enablePreview = true;
                    status = 'Stopped';
                case RigState.STOPPING
                    status = 'Stopping...';
                case RigState.PAUSED
                    enableRecord = hasExperiment;
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
            
            [valid, msg] = obj.mainService.validate();
            if ~valid
                enableRecord = false;
                enablePreview = false;
                enablePause = false;
                enableStop = false;
                status = msg;
            end
            
            obj.view.enableNewExperiment(enableNewExperiment);
            obj.view.enableCloseExperiment(enableCloseExperiment);
            obj.view.enableViewExperiment(enableViewExperiment);
            obj.view.enableAddNote(enableAddNote);
            obj.view.enableSelectRig(enableSelectRig);
            obj.view.enableSettings(enableSettings);
            obj.view.enableSelectProtocol(enableSelectProtocol);
            obj.view.enableProtocolParameters(enableProtocolParameters);
            obj.view.enableRecord(enableRecord);
            obj.view.enablePreview(enablePreview);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.setStatus(status);
        end
        
        function onViewSelectedSettings(obj, ~, ~)
            view = symphonyui.ui.views.SettingsView(obj.view);
            p = symphonyui.ui.presenters.SettingsPresenter(view);
            p.view.showDialog();
        end
        
        function onViewSelectedDocumentation(obj, ~, ~)
            web(obj.app.documentationUrl);
        end
        
        function onViewSelectedUserGroup(obj, ~, ~)
            web(obj.app.userGroupUrl);
        end
        
        function onViewSelectedAboutSymphony(obj, ~, ~)
            message = { ...
                sprintf('%s Data Acquisition System', obj.app.displayName), ...
                sprintf('Version %s', obj.app.version), ...
                sprintf('%c %s Symphony-DAS', 169, datestr(now, 'YYYY'))};
            obj.view.showMessage(message, 'About Symphony');
        end
        
        function onViewSelectedExit(obj, ~, ~)
            obj.view.close();
        end
        
    end
    
end

