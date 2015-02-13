classdef MainPresenter < symphonyui.Presenter
    
    properties (Access = private)
        controller
        protocolMap
    end
    
    properties (Access = private)
        preferences = symphonyui.app.Preferences.getDefault();
    end
    
    methods
        
        function obj = MainPresenter(controller, view)            
            if nargin < 2
                view = symphonyui.views.MainView();
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.controller = controller;
            
            obj.addListener(controller, 'OpenedExperiment', @obj.onOpenedExperiment);
            obj.addListener(controller, 'ClosedExperiment', @obj.onClosedExperiment);
            obj.addListener(controller, 'BeganEpochGroup', @obj.onBeganEpochGroup);
            obj.addListener(controller, 'EndedEpochGroup', @obj.onEndedEpochGroup);
            obj.addListener(controller, 'InitializedRig', @obj.onInitializedRig);
            obj.addListener(controller, 'ChangedProtocolList', @obj.onChangedProtocolList);
            obj.addListener(controller, 'SelectedProtocol', @obj.onControllerSelectedProtocol);
            obj.addListener(controller, 'ChangedProtocolParameters', @obj.onControllerChangedProtocolParameters);
            obj.addListener(controller, 'ChangedState', @obj.onControllerChangedState);
            
            obj.addListener(view, 'NewExperiment', @obj.onSelectedNewExperiment);
            obj.addListener(view, 'CloseExperiment', @obj.onSelectedCloseExperiment);
            obj.addListener(view, 'BeginEpochGroup', @obj.onSelectedBeginEpochGroup);
            obj.addListener(view, 'EndEpochGroup', @obj.onSelectedEndEpochGroup);
            obj.addListener(view, 'SelectedProtocol', @obj.onViewSelectedProtocol);
            obj.addListener(view, 'ChangedProtocolParameters', @obj.onViewChangedProtocolParameters);
            obj.addListener(view, 'Record', @obj.onSelectedRecord);
            obj.addListener(view, 'Preview', @obj.onSelectedPreview);
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
            
            obj.onChangedProtocolList();
            obj.onControllerSelectedProtocol();
            obj.updateViewState();
        end
        
        function onViewClosing(obj, ~, ~)
            onViewClosing@symphonyui.Presenter(obj);
            obj.view.savePosition();
            delete(obj.controller);            
        end
        
    end
    
    methods (Access = private)
        
        function onSelectedNewExperiment(obj, ~, ~)
            view = symphonyui.views.NewExperimentView(obj.view);
            p = symphonyui.presenters.NewExperimentPresenter(obj.controller, view);
            p.view.showDialog();
        end
        
        function onOpenedExperiment(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onSelectedCloseExperiment(obj, ~, ~)
            obj.controller.closeExperiment();
        end
        
        function onClosedExperiment(obj, ~, ~)
            obj.updateViewState();
        end
        
        function onSelectedBeginEpochGroup(obj, ~, ~)
            view = symphonyui.views.BeginEpochGroupView(obj.view);
            p = symphonyui.presenters.BeginEpochGroupPresenter(obj.controller, view);
            p.view.showDialog();
        end
        
        function onBeganEpochGroup(obj, ~, ~)
            obj.view.enableEndEpochGroup(true);
        end
        
        function onSelectedEndEpochGroup(obj, ~, ~)
            view = symphonyui.views.EndEpochGroupView(obj.view);
            p = symphonyui.presenters.EndEpochGroupPresenter(obj.controller, view);
            p.view.showDialog();
        end
        
        function onEndedEpochGroup(obj, ~, ~)
            obj.view.enableEndEpochGroup(obj.controller.hasEpochGroup);
        end
        
        function onSelectedAddNote(obj, ~, ~)
            disp('Selected Add Note');
        end
        
        function onSelectedViewNotes(obj, ~, ~)
            disp('Selected View Notes');
        end
        
        function onChangedProtocolList(obj, ~, ~)
            obj.protocolMap = symphonyui.util.displayNameMap(obj.controller.protocolList);
            obj.view.setProtocolList(obj.protocolMap.keys);
        end
        
        function onViewSelectedProtocol(obj, ~, ~)
            key = obj.view.getProtocol();
            className = obj.protocolMap(key);
            index = obj.controller.getProtocolIndex(className);
            
            try
                obj.controller.selectProtocol(index);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
        end
        
        function onControllerSelectedProtocol(obj, ~, ~)
            index = obj.controller.getProtocolIndex();
            key = obj.protocolMap.right_at(index);
            obj.view.setProtocol(key);
            
            try
                parameters = obj.controller.getProtocolParameters();
                parameters(parameters.findIndexByName('displayName')) = [];
                obj.view.setProtocolParameters(parameters);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.view.clearProtocolPresets();
            
            obj.updateViewState();
        end
        
        function onViewChangedProtocolParameters(obj, ~, ~)
            parameters = obj.view.getProtocolParameters();
            obj.controller.setProtocolParameters(parameters);
        end
        
        function onControllerChangedProtocolParameters(obj, ~, ~)
            try
                parameters = obj.controller.getProtocolParameters();
                parameters(parameters.findIndexByName('displayName')) = [];
                obj.view.updateProtocolParameters(parameters);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.updateViewState();
        end
        
        function onSelectedRecord(obj, ~, ~)
            obj.controller.record();
        end
        
        function onSelectedPreview(obj, ~, ~)
            obj.controller.preview();
        end
        
        function onSelectedPause(obj, ~, ~)
            obj.controller.pause();
        end
        
        function onSelectedStop(obj, ~, ~)
            obj.controller.stop();
        end
        
        function onControllerChangedState(obj, ~, ~)
            obj.updateViewState();
        end
        
        function updateViewState(obj)
            import symphonyui.models.*;
            
            hasExperiment = obj.controller.hasExperiment;
            hasEpochGroup = obj.controller.hasEpochGroup;
            isStopped = obj.controller.state == AcquisitionState.STOPPED;
            
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
            enableRecord = false;
            enablePreview = false;
            enablePause = false;
            enableStop = false;
            status = 'Unknown';
            
            switch obj.controller.state
                case AcquisitionState.STOPPED
                    enableRecord = hasExperiment;
                    enablePreview = true;
                    status = 'Stopped';
                case AcquisitionState.STOPPING
                    status = 'Stopping...';
                case AcquisitionState.PAUSED
                    enableRecord = hasExperiment;
                    enablePreview = true;
                    enableStop = true;
                    status = 'Paused';
                case AcquisitionState.PAUSING
                    enableStop = true;
                    status = 'Pausing...';
                case AcquisitionState.PREVIEWING
                    enablePause = true;
                    enableStop = true;
                    status = 'Previewing...';
                case AcquisitionState.RECORDING
                    enablePause = true;
                    enableStop = true;
                    status = 'Recording...';
            end
            
            [valid, msg] = obj.controller.validate();
            if ~valid
                enableRecord = false;
                enablePreview = false;
                enablePause = false;
                enableStop = false;
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
            obj.view.enableRecord(enableRecord);
            obj.view.enablePreview(enablePreview);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.setStatus(status);
        end
        
        function onSelectedSelectRig(obj, ~, ~)
            view = symphonyui.views.SelectRigView(obj.view);
            p = symphonyui.presenters.SelectRigPresenter(obj.controller, view);
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

