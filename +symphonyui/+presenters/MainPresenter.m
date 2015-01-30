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
            %view.loadPosition();
            
            obj.appData = symphonyui.AppData(preferences);
            obj.addListener(obj.appData, 'SetRig', @obj.onSetRig);
            obj.addListener(obj.appData, 'SetExperiment', @obj.onSetExperiment);
            obj.addListener(obj.appData, 'SetProtocol', @obj.onSetProtocol);
            obj.addListener(obj.appData, 'SetProtocolList', @obj.onSetProtocolList);
            obj.addListener(obj.appData, 'SetControllerState', @obj.onSetControllerState);
            
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
            
            view.enableNewExperiment(true);
            view.enableCloseExperiment(false);
            view.enableBeginEpochGroup(false);
            view.enableEndEpochGroup(false);
            view.enableAddNote(false);
            view.enableViewNotes(false);
            view.enableRun(false);
            view.enablePause(false);
            view.enableStop(false);
            view.enableShouldSave(false);
            view.enableStatus(false);
            
            obj.onSetProtocolList();
            obj.onSelectedSetRig();
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
        
        function onSelectedProtocol(obj, ~, ~)
            protocol = obj.view.getProtocol();
            className = obj.protocolMap(protocol);
            index = ismember(obj.appData.protocolList, className);
            try
                obj.appData.setProtocol(index);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                obj.onSetProtocol();
            end
        end
        
        function onSetProtocol(obj, ~, ~)
            protocol = obj.appData.protocol;
            index = obj.protocolMap.right_find(class(protocol));
            key = obj.protocolMap.right_at(index);
            obj.view.setProtocol(key);
            
            parameters = obj.appData.protocol.parameters;
            parameters = rmfield(parameters, 'displayName');
            obj.view.setProtocolParameters(struct2cell(parameters));
        end
        
        function onChangedProtocolParameter(obj, ~, ~)
            protocol = obj.appData.protocol;
            parameters = obj.view.getProtocolParameters();
            for i = 1:numel(parameters)
                p = parameters{i};
                if ~p.readOnly
                    try
                        protocol.(p.name) = p.value;
                    catch x
                        symphonyui.presenters.MessageBoxPresenter.showException(x);
                    end
                end
            end
            obj.view.updateProtocolParameters(struct2cell(protocol.parameters));
        end
        
        function onSetProtocolList(obj, ~, ~)
            obj.protocolMap = displayNameMap(obj.appData.protocolList);
            obj.view.setProtocolList(obj.protocolMap.keys);
            try %#ok<TRYNC>
                obj.appData.setProtocol(2);
            end
        end
        
        function onSelectedRun(obj, ~, ~)
            p = obj.appData.protocol;
            obj.appData.controller.runProtocol(p);
        end
        
        function onSelectedPause(obj, ~, ~)
            obj.appData.controller.pause();
        end
        
        function onSelectedStop(obj, ~, ~)
            obj.appData.controller.stop();
        end
        
        function onSetControllerState(obj, ~, ~)
            import symphonyui.models.*;
            
            enableSelectProtocol = false;
            enableProtocolParameters = false;
            enableRun = false;
            enablePause = false;
            enableStop = false;
            enableShouldSave = false;
            enableStatus = false;
            status = 'Unknown';
            
            switch obj.appData.controller.state
                case ControllerState.STOPPED
                    enableSelectProtocol = true;
                    enableProtocolParameters = true;
                    enableRun = true;
                    enableShouldSave = true;
                    enableStatus = true;
                    status = 'Stopped';
                case ControllerState.STOPPING
                    enableStatus = true;
                    status = 'Stopping';
                case ControllerState.PAUSED
                    enableRun = true;
                    enableStop = true;
                    enableShouldSave = true;
                    enableStatus = true;
                    status = 'Paused';
                case ControllerState.PAUSING
                    enableStop = true;
                    enableStatus = true;
                    status = 'Pausing';
                case ControllerState.RUNNING
                    enablePause = true;
                    enableStop = true;
                    enableStatus = true;
                    status = 'Running';
            end
            
            obj.view.enableSelectProtocol(enableSelectProtocol && ~isempty(obj.appData.protocol));
            obj.view.enableProtocolParameters(enableProtocolParameters && ~isempty(obj.appData.protocol));
            obj.view.enableRun(enableRun);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.enableShouldSave(enableShouldSave && ~isempty(obj.appData.experiment));
            obj.view.enableStatus(enableStatus);
            obj.view.setStatus(status);
        end
        
        function onSelectedSetRig(obj, ~, ~)
            controller = obj.appData.controller;
            rigMap = displayNameMap(obj.appData.rigList);
            view = symphonyui.views.SetRigView(obj.view);
            p = symphonyui.presenters.SetRigPresenter(controller, rigMap, view);
            p.view.showDialog();
        end
        
        function onSetRig(obj, ~, ~)
            obj.onSelectedProtocol();
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
    
    methods (Access = protected)
        
        function onViewClosing(obj, ~, ~)
            onViewClosing@symphonyui.Presenter(obj);
            obj.view.savePosition();
        end
        
    end
    
end

function map = displayNameMap(list)
    map = Map2();
    for i = 1:numel(list);
        className = list{i};
        displayName = symphonyui.utilities.classProperty(className, 'displayName');
        if isKey(map, displayName)
            value = map(displayName);
            map.remove(displayName);
            map([displayName ' (' value ')']) = value;
            
            displayName = [displayName ' (' className ')'];
        end
        map(displayName) = className;
    end
end

