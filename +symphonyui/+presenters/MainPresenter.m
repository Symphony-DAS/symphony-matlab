classdef MainPresenter < symphonyui.Presenter
    
    properties (Access = private)
        appController
        protocolMap
    end
    
    properties (Access = private)
        preferences = symphonyui.app.Preferences.getDefault();
    end
    
    methods
        
        function obj = MainPresenter(appController, view)            
            if nargin < 2
                view = symphonyui.views.MainView();
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.appController = appController;
            
            obj.addListener(appController, 'OpenedExperiment', @obj.onOpenedExperiment);
            obj.addListener(appController, 'ClosedExperiment', @obj.onClosedExperiment);
            obj.addListener(appController, 'BeganEpochGroup', @obj.onBeganEpochGroup);
            obj.addListener(appController, 'EndedEpochGroup', @obj.onEndedEpochGroup);
            obj.addListener(appController, 'InitializedRig', @obj.onInitializedRig);
            obj.addListener(appController, 'SetProtocolList', @obj.onSetProtocolList);
            obj.addListener(appController, 'SelectedProtocol', @obj.onControllerSelectedProtocol);
            obj.addListener(appController, 'ChangedState', @obj.onControllerChangedState);
            
            obj.addListener(view, 'NewExperiment', @obj.onSelectedNewExperiment);
            obj.addListener(view, 'CloseExperiment', @obj.onSelectedCloseExperiment);
            obj.addListener(view, 'BeginEpochGroup', @obj.onSelectedBeginEpochGroup);
            obj.addListener(view, 'EndEpochGroup', @obj.onSelectedEndEpochGroup);
            obj.addListener(view, 'SelectedProtocol', @obj.onViewSelectedProtocol);
            obj.addListener(view, 'ChangedProtocolParameter', @obj.onChangedProtocolParameter);
            obj.addListener(view, 'Run', @obj.onSelectedRun);
            obj.addListener(view, 'Pause', @obj.onSelectedPause);
            obj.addListener(view, 'Stop', @obj.onSelectedStop);
            obj.addListener(view, 'SelectRig', @obj.onSelectedSelectRig);
            obj.addListener(view, 'Preferences', @obj.onSelectedPreferences);
            obj.addListener(view, 'Documentation', @obj.onSelectedDocumentation);
            obj.addListener(view, 'UserGroup', @obj.onSelectedUserGroup);
            obj.addListener(view, 'AboutSymphony', @obj.onSelectedAboutSymphony);
            obj.addListener(view, 'Exit', @(h,d)view.close());
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.Presenter(obj);
            %view.loadPosition();
            
            obj.onSetProtocolList();
            obj.onControllerSelectedProtocol();
            obj.updateViewState();
        end
        
        function onViewClosing(obj, ~, ~)
            onViewClosing@symphonyui.Presenter(obj);
            obj.view.savePosition();
            delete(obj.appController);            
        end
        
    end
    
    methods (Access = private)
        
        function onSelectedNewExperiment(obj, ~, ~)
            view = symphonyui.views.NewExperimentView(obj.view);
            p = symphonyui.presenters.NewExperimentPresenter(obj.appController, view);
            p.view.showDialog();
        end
        
        function onOpenedExperiment(obj, ~, ~)
            obj.updateViewState();
            obj.view.setShouldSave(true);
        end
        
        function onSelectedCloseExperiment(obj, ~, ~)
            obj.appController.closeExperiment();
        end
        
        function onClosedExperiment(obj, ~, ~)
            obj.updateViewState();
            obj.view.setShouldSave(false);
        end
        
        function onSelectedBeginEpochGroup(obj, ~, ~)
            view = symphonyui.views.BeginEpochGroupView(obj.view);
            p = symphonyui.presenters.BeginEpochGroupPresenter(obj.appController, view);
            p.view.showDialog();
        end
        
        function onBeganEpochGroup(obj, ~, ~)
            obj.view.enableEndEpochGroup(true);
        end
        
        function onSelectedEndEpochGroup(obj, ~, ~)
            obj.appController.endEpochGroup();
        end
        
        function onEndedEpochGroup(obj, ~, ~)
            obj.view.enableEndEpochGroup(obj.appController.hasEpochGroup);
        end
        
        function onSelectedAddNote(obj, ~, ~)
            disp('Selected Add Note');
        end
        
        function onSelectedViewNotes(obj, ~, ~)
            disp('Selected View Notes');
        end
        
        function onSetProtocolList(obj, ~, ~)
            obj.protocolMap = symphonyui.util.displayNameMap(obj.appController.protocolList);
            obj.view.setProtocolList(obj.protocolMap.keys);
        end
        
        function onViewSelectedProtocol(obj, ~, ~)
            key = obj.view.getProtocol();
            className = obj.protocolMap(key);
            index = obj.appController.getProtocolIndex(className);
            
            try
                obj.appController.selectProtocol(index);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
        end
        
        function onControllerSelectedProtocol(obj, ~, ~)
            protocol = obj.appController.protocol;
            index = obj.protocolMap.right_find(class(protocol));
            key = obj.protocolMap.right_at(index);
            obj.view.setProtocol(key);
            
            try
                parameters = protocol.getParameters();
                parameters(parameters.findIndexByName('displayName')) = [];
                obj.view.setProtocolParameters(parameters);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.view.clearProtocolPresets();
            obj.view.addProtocolPreset(protocol.displayName);
            
            obj.updateViewState();
        end
        
        function onChangedProtocolParameter(obj, ~, ~)
            protocol = obj.appController.protocol;
            parameters = obj.view.getProtocolParameters();
            for i = 1:numel(parameters)
                p = parameters(i);
                if p.isReadOnly
                    continue;
                end
                protocol.(p.name) = p.value;
            end
            
            try
                parameters = protocol.getParameters();
                parameters(parameters.findIndexByName('displayName')) = [];
                obj.view.updateProtocolParameters(parameters);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.updateViewState();
        end
        
        function onSelectedRun(obj, ~, ~)
            obj.appController.run();
        end
        
        function onSelectedPause(obj, ~, ~)
            obj.appController.pause();
        end
        
        function onSelectedStop(obj, ~, ~)
            obj.appController.stop();
        end
        
        function onControllerChangedState(obj, ~, ~)
            obj.updateViewState();
        end
        
        function updateViewState(obj)
            import symphonyui.models.*;
            
            hasExperiment = obj.appController.hasExperiment;
            hasEpochGroup = obj.appController.hasEpochGroup;
            isStopped = obj.appController.state == ControllerState.STOPPED;
            
            enableNewExperiment = ~hasExperiment && isStopped;
            enableCloseExperiment = hasExperiment && isStopped;
            enableBeginEpochGroup = hasExperiment && isStopped;
            enableEndEpochGroup = hasEpochGroup && isStopped;
            enableAddNote = hasExperiment;
            enableViewNotes = hasExperiment;
            enableSelectRig = ~hasExperiment && isStopped;
            enablePreferences = ~hasExperiment && isStopped;
            enableSelectProtocol = isStopped;
            enableProtocolParameters = isStopped;
            enableProtocolPresets = isStopped;
            enableShouldSave = hasExperiment && isStopped;
            enableRun = false;
            enablePause = false;
            enableStop = false;
            status = 'Unknown';
            
            switch obj.appController.state
                case ControllerState.STOPPED
                    enableRun = true;
                    status = 'Stopped';
                case ControllerState.STOPPING
                    status = 'Stopping';
                case ControllerState.PAUSED
                    enableRun = true;
                    enableStop = true;
                    status = 'Paused';
                case ControllerState.PAUSING
                    enableStop = true;
                    status = 'Pausing';
                case ControllerState.RUNNING
                    enablePause = true;
                    enableStop = true;
                    status = 'Running';
            end
            
            [valid, msg] = obj.appController.validate();
            if ~valid
                enableRun = false;
                enableStop = false;
                enableShouldSave = false;
                status = msg;
            end
            
            obj.view.enableNewExperiment(enableNewExperiment);
            obj.view.enableCloseExperiment(enableCloseExperiment);
            obj.view.enableBeginEpochGroup(enableBeginEpochGroup);
            obj.view.enableEndEpochGroup(enableEndEpochGroup);
            obj.view.enableAddNote(enableAddNote);
            obj.view.enableViewNotes(enableViewNotes);
            obj.view.enableSelectRig(enableSelectRig);
            obj.view.enablePreferences(enablePreferences);
            obj.view.enableSelectProtocol(enableSelectProtocol);
            obj.view.enableProtocolParameters(enableProtocolParameters);
            obj.view.enableProtocolPresets(enableProtocolPresets);
            obj.view.enableShouldSave(enableShouldSave);
            obj.view.enableRun(enableRun);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.setStatus(status);
        end
        
        function onSelectedSelectRig(obj, ~, ~)
            view = symphonyui.views.SelectRigView(obj.view);
            p = symphonyui.presenters.SelectRigPresenter(obj.appController, view);
            p.view.showDialog();
        end
        
        function onInitializedRig(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onSelectedPreferences(obj, ~, ~)
            view = symphonyui.views.PreferencesView(obj.view);
            p = symphonyui.presenters.PreferencesPresenter(obj.preferences, view);
            p.view.showDialog();
        end
        
        function onSelectedDocumentation(obj, ~, ~)
            web('https://github.com/Symphony-DAS/Symphony/wiki');
        end
        
        function onSelectedUserGroup(obj, ~, ~)
            web('https://groups.google.com/forum/#!forum/symphony-das');
        end
        
        function onSelectedAboutSymphony(obj, ~, ~)
            message = { ...
                'Symphony Data Acquisition System', ...
                'Version 2.0.0-preview', ...
                sprintf('%c 2015 Symphony-DAS', 169)};
            p = symphonyui.presenters.MessageBoxPresenter(message, 'About Symphony');
            p.view.showDialog();
        end
        
    end
    
end

