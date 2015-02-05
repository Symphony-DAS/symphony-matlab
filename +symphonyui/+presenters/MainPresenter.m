classdef MainPresenter < symphonyui.Presenter
    
    properties (Access = private)
        appData
        protocolMap
    end
    
    methods
        
        function obj = MainPresenter(preferences, view)            
            if nargin < 2
                view = symphonyui.views.MainView();
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.appData = symphonyui.AppData(preferences);
            obj.addListener(obj.appData, 'SetExperiment', @obj.onSetExperiment);
            obj.addListener(obj.appData, 'SetProtocolList', @obj.onSetProtocolList);
            obj.addListener(obj.appData, 'SetProtocol', @obj.onSetProtocol);
            obj.addListener(obj.appData.controller, 'state', 'PostSet', @obj.onSetControllerState);
            
            obj.addListener(view, 'NewExperiment', @obj.onSelectedNewExperiment);
            obj.addListener(view, 'CloseExperiment', @obj.onSelectedCloseExperiment);
            obj.addListener(view, 'BeginEpochGroup', @obj.onSelectedBeginEpochGroup);
            obj.addListener(view, 'EndEpochGroup', @obj.onSelectedEndEpochGroup);
            obj.addListener(view, 'SelectedProtocol', @obj.onSelectedProtocol);
            obj.addListener(view, 'ChangedProtocolParameter', @obj.onChangedProtocolParameter);
            obj.addListener(view, 'Run', @obj.onSelectedRun);
            obj.addListener(view, 'Pause', @obj.onSelectedPause);
            obj.addListener(view, 'Stop', @obj.onSelectedStop);
            obj.addListener(view, 'SetRig', @obj.onSelectedSetRig);
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
            
            obj.view.enableNewExperiment(true);
            obj.view.enableCloseExperiment(false);
            obj.view.enableBeginEpochGroup(false);
            obj.view.enableEndEpochGroup(false);
            obj.view.enableAddNote(false);
            obj.view.enableViewNotes(false);
            obj.view.enableRun(false);
            obj.view.enablePause(false);
            obj.view.enableStop(false);
            obj.view.enableShouldSave(false);
            
            obj.onSetProtocolList();
            obj.onSetProtocol();
            obj.onSelectedSetRig();
            obj.validate();
        end
        
        function onViewClosing(obj, ~, ~)
            onViewClosing@symphonyui.Presenter(obj);
            obj.view.savePosition();
        end
        
    end
    
    methods (Access = private)
        
        function onSelectedNewExperiment(obj, ~, ~)
            view = symphonyui.views.NewExperimentView(obj.view);
            p = symphonyui.presenters.NewExperimentPresenter(obj.appData.experimentPreferences, view);
            result = p.view.showDialog();
            if result
                obj.appData.setExperiment(p.experiment);
            end
        end
        
        function onSelectedCloseExperiment(obj, ~, ~)
            obj.appData.experiment.close();
            obj.appData.setExperiment([]);
        end
        
        function onSetExperiment(obj, ~, ~)
            hasExperiment = obj.appData.hasExperiment;
            
            obj.view.enableNewExperiment(~hasExperiment);
            obj.view.enableCloseExperiment(hasExperiment);
            obj.view.enableBeginEpochGroup(hasExperiment);
            obj.view.enableAddNote(hasExperiment);
            obj.view.enableViewNotes(hasExperiment);
            obj.view.enableSetRig(~hasExperiment);
            obj.view.enableShouldSave(hasExperiment);
            obj.view.setShouldSave(hasExperiment);
        end
        
        function onSelectedBeginEpochGroup(obj, ~, ~)
            experiment = obj.appData.experiment;
            preferences = obj.appData.epochGroupPreferences;
            view = symphonyui.views.NewEpochGroupView(obj.view);
            p = symphonyui.presenters.NewEpochGroupPresenter(experiment, preferences, view);
            p.view.showDialog();
        end
        
        function onBeganEpochGroup(obj, ~, ~)
            obj.view.enableEndEpochGroup(true);
        end
        
        function onSelectedEndEpochGroup(obj, ~, ~)
            obj.appData.experiment.endEpochGroup();
        end
        
        function onEndedEpochGroup(obj, ~, ~)
            if isempty(obj.appData.experiment.epochGroup)
                obj.view.enableEndEpochGroup(false);
            end
        end
        
        function onSelectedAddNote(obj, ~, ~)
            disp('Selected Add Note');
        end
        
        function onSelectedViewNotes(obj, ~, ~)
            disp('Selected View Notes');
        end
        
        function onSetProtocolList(obj, ~, ~)
            obj.protocolMap = symphonyui.utilities.displayNameMap(obj.appData.protocolList);
            obj.view.setProtocolList(obj.protocolMap.keys);
        end
        
        function onSelectedProtocol(obj, ~, ~)
            protocol = obj.view.getProtocol();
            className = obj.protocolMap(protocol);
            index = find(ismember(obj.appData.protocolList, className), 1);
            if index == obj.appData.getProtocolIndex()
                return;
            end
            
            try
                obj.appData.setProtocol(index);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                obj.onSetProtocol();
                return;
            end
        end
        
        function onSetProtocol(obj, ~, ~)
            protocol = obj.appData.protocol;
            index = obj.protocolMap.right_find(class(protocol));
            key = obj.protocolMap.right_at(index);
            obj.view.setProtocol(key);
            
            try
                parameters = obj.appData.protocol.parameters;
                parameters = rmfield(parameters, 'displayName');
                obj.view.setProtocolParameters(struct2cell(parameters));
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                obj.appData.setProtocol(1);
                obj.onSetProtocol();
                return;
            end
            
            obj.validate();
        end
        
        function onChangedProtocolParameter(obj, ~, ~)
            protocol = obj.appData.protocol;
            parameters = obj.view.getProtocolParameters();
            for i = 1:numel(parameters)
                p = parameters{i};
                if p.isReadOnly
                    continue;
                end
                try
                    protocol.(p.name) = p.value;
                catch x
                    symphonyui.presenters.MessageBoxPresenter.showException(x);
                    warning(getReport(x));
                end
            end
            try
                parameters = obj.appData.protocol.parameters;
                obj.view.updateProtocolParameters(struct2cell(parameters));
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                obj.appData.setProtocol(1);
                return;
            end
            
            obj.validate();
        end
        
        function onSelectedRun(obj, ~, ~)
            obj.appData.controller.runProtocol(obj.appData.protocol);
        end
        
        function onSelectedPause(obj, ~, ~)
            obj.appData.controller.pause();
        end
        
        function onSelectedStop(obj, ~, ~)
            obj.appData.controller.stop();
        end
        
        function onSetControllerState(obj, ~, ~)
            import symphonyui.models.*;
            
            enableNewExperiment = false;
            enableCloseExperiment = false;
            enableBeginEpochGroup = false;
            enableEndEpochGroup = false;
            enableSetRig = false;
            enablePreferences = false;
            enableSelectProtocol = false;
            enableProtocolParameters = false;
            enableProtocolPresets = false;
            enableRun = false;
            enablePause = false;
            enableStop = false;
            enableShouldSave = false;
            
            switch obj.appData.controller.state
                case ControllerState.STOPPED
                    enableNewExperiment = true;
                    enableCloseExperiment = true;
                    enableBeginEpochGroup = true;
                    enableEndEpochGroup = true;
                    enableSetRig = true;
                    enablePreferences = true;
                    enableSelectProtocol = true;
                    enableProtocolParameters = true;
                    enableProtocolPresets = true;
                    enableRun = true;
                    enableShouldSave = true;
                    status = 'Stopped';
                case ControllerState.STOPPING
                    status = 'Stopping';
                case ControllerState.PAUSED
                    enableRun = true;
                    enableStop = true;
                    enableShouldSave = true;
                    status = 'Paused';
                case ControllerState.PAUSING
                    enableStop = true;
                    status = 'Pausing';
                case ControllerState.RUNNING
                    enablePause = true;
                    enableStop = true;
                    status = 'Running';
                otherwise
                    status = 'Unknown state'; 
            end
            
            obj.view.enableNewExperiment(enableNewExperiment && isempty(obj.appData.experiment));
            obj.view.enableCloseExperiment(enableCloseExperiment && ~isempty(obj.appData.experiment));
            obj.view.enableBeginEpochGroup(enableBeginEpochGroup && ~isempty(obj.appData.experiment));
            obj.view.enableEndEpochGroup(enableEndEpochGroup && ~isempty(obj.appData.experiment) && ~isempty(obj.appData.experiment.epochGroup));
            obj.view.enableSetRig(enableSetRig && isempty(obj.appData.experiment));
            obj.view.enablePreferences(enablePreferences);
            obj.view.enableSelectProtocol(enableSelectProtocol);
            obj.view.enableProtocolParameters(enableProtocolParameters);
            obj.view.enableProtocolPresets(enableProtocolPresets);
            obj.view.enableRun(enableRun);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.enableShouldSave(enableShouldSave && ~isempty(obj.appData.experiment));
            obj.view.setStatus(status);
        end
        
        function validate(obj)
            [valid, msg] = obj.appData.controller.validateProtocol(obj.appData.protocol);
            if ~valid
                obj.view.enableRun(false);
                obj.view.enablePause(false);
                obj.view.enableStop(false);
                obj.view.enableShouldSave(false);
                obj.view.setStatus(msg);
            else
                obj.onSetControllerState();
            end
        end
        
        function onSelectedSetRig(obj, ~, ~)
            view = symphonyui.views.SetRigView(obj.view);
            p = symphonyui.presenters.SetRigPresenter(obj.appData, view);
            result = p.view.showDialog();
            if result
                obj.onChangedProtocolParameter();
            end
        end
        
        function onSelectedPreferences(obj, ~, ~)
            preferences = obj.appData.preferences;
            view = symphonyui.views.AppPreferencesView(obj.view);
            p = symphonyui.presenters.AppPreferencesPresenter(preferences, view);
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

