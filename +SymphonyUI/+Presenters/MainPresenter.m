classdef MainPresenter < SymphonyUI.Presenter
    
    properties (SetAccess = private)
        appData
    end
    
    properties (Access = private)
        parametersPresenter
    end
    
    methods
        
        function obj = MainPresenter(appPreference, view)
            if nargin < 2
                view = SymphonyUI.Views.MainView();
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            %view.loadPosition();
            
            obj.appData = SymphonyUI.AppData(appPreference);
            obj.addListener(obj.appData, 'SetExperiment', @obj.onSetExperiment);
            obj.addListener(obj.appData, 'SetProtocol', @obj.onSetProtocol);
            obj.addListener(obj.appData, 'SetController', @obj.onSetController);
            obj.addListener(obj.appData, 'BeganEpochGroup', @obj.onBeganEpochGroup);
            obj.addListener(obj.appData, 'EndedEpochGroup', @obj.onEndedEpochGroup);
            obj.addListener(obj.appData, 'SetState', @obj.onSetState);
            
            obj.addListener(view, 'NewExperiment', @obj.onSelectedNewExperiment);
            obj.addListener(view, 'CloseExperiment', @obj.onSelectedCloseExperiment);
            obj.addListener(view, 'BeginEpochGroup', @obj.onSelectedBeginEpochGroup);
            obj.addListener(view, 'EndEpochGroup', @obj.onSelectedEndEpochGroup);
            obj.addListener(view, 'SelectedProtocol', @obj.onSelectedProtocol);
            obj.addListener(view, 'ProtocolParameters', @obj.onSelectedProtocolParameters);
            obj.addListener(view, 'Run', @obj.onSelectedRun);
            obj.addListener(view, 'Pause', @obj.onSelectedPause);
            obj.addListener(view, 'Stop', @obj.onSelectedStop);
            obj.addListener(view, 'Preferences', @obj.onSelectedPreferences);
            obj.addListener(view, 'Documentation', @obj.onSelectedDocumentation);
            obj.addListener(view, 'UserGroup', @obj.onSelectedUserGroup);
            obj.addListener(view, 'AboutSymphony', @obj.onSelectedAboutSymphony);
            obj.addListener(view, 'Exit', @(h,d)view.close());
            
            view.enableNewExperiment(true);
            view.enableCloseExperiment(false);
            view.enableBeginEpochGroup(false);
            view.enableEndEpochGroup(false);
            view.enableViewNotes(false);
            view.enableAddNote(false);
            view.enableViewRig(false);
            view.enableSelectProtocol(false);
            view.enableProtocolParameters(false);
            view.enableRun(false);
            view.enablePause(false);
            view.enableStop(false);
            view.enableShouldSave(false);
            view.enableStatus(false);
        end
        
    end
    
    methods (Access = private)
        
        function onSelectedNewExperiment(obj, ~, ~)
            view = SymphonyUI.Views.NewExperimentView(obj.view);
            p = SymphonyUI.Presenters.NewExperimentPresenter(view);
            result = p.view.showDialog();
            if result
                obj.appData.setExperiment(p.experiment);
            end
        end
        
        function onSelectedCloseExperiment(obj, ~, ~)
            obj.appData.experiment.close();
            obj.appData.setController([]);
            obj.appData.setProtocol([]);
            obj.appData.setExperiment([]);
        end
        
        function onSetExperiment(obj, ~, ~)
            hasExperiment = ~isempty(obj.appData.experiment);
            
            obj.view.enableNewExperiment(~hasExperiment);
            obj.view.enableCloseExperiment(hasExperiment);
            obj.view.enableBeginEpochGroup(hasExperiment);
            obj.view.enableViewNotes(hasExperiment);
            obj.view.enableAddNote(hasExperiment);
            obj.view.enableViewRig(hasExperiment);
            obj.view.enableSelectProtocol(hasExperiment);
            
            if hasExperiment
                obj.onSelectedProtocol();
                obj.appData.setController(SymphonyUI.Models.Controller());
            end
        end
        
        function onSelectedBeginEpochGroup(obj, ~, ~)
            experiment = obj.appData.experiment;
            preference = obj.appData.appPreference.epochGroupPreference;
            view = SymphonyUI.Views.NewEpochGroupView(obj.view);
            p = SymphonyUI.Presenters.NewEpochGroupPresenter(experiment, preference, view);
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
        
        function onSelectedViewNotes(obj, ~, ~)
            disp('Selected View Notes');
        end
        
        function onSelectedAddNote(obj, ~, ~)
            disp('Selected Add Note');
        end
        
        function onSelectedViewRig(obj, ~, ~)
            disp('Selected View Rig');
        end
        
        function onSelectedProtocol(obj, ~, ~)
            p = obj.view.getProtocol();
            obj.appData.setProtocol(p);
        end
        
        function onSetProtocol(obj, ~, ~)
            hasProtocol = ~isempty(obj.appData.protocol);
            
            obj.view.enableProtocolParameters(hasProtocol);
            
            if hasProtocol
                obj.view.setProtocol(obj.appData.protocol);
            end
            
            if ~isempty(obj.parametersPresenter)
                if hasProtocol
                    obj.parametersPresenter.setProtocol(obj.appData.protocol);
                else
                    obj.parametersPresenter.view.close();
                end
            end
        end
        
        function onSelectedProtocolParameters(obj, ~, ~)
            if isempty(obj.parametersPresenter)
                v = SymphonyUI.Views.ProtocolParametersView(obj.view);
                obj.parametersPresenter = SymphonyUI.Presenters.ProtocolParametersPresenter(v);
                obj.addListener(obj.parametersPresenter.view, 'Closing', @obj.onProtocolPresenterClosing);                
                obj.parametersPresenter.setProtocol(obj.appData.protocol);
            end
            obj.parametersPresenter.view.show();
        end
        
        function onProtocolPresenterClosing(obj, ~, ~)
            obj.parametersPresenter = [];
        end
        
        function onSetController(obj, ~, ~)
            hasController = ~isempty(obj.appData.controller);
            if hasController
                obj.onSetState();
            else
                obj.view.enableRun(false);
                obj.view.enablePause(false);
                obj.view.enableStop(false);
                obj.view.enableShouldSave(false);
                obj.view.enableStatus(false);
            end
        end
        
        function onSelectedRun(obj, ~, ~)
            p = obj.appData.protocol;
            e = obj.appData.experiment;
            obj.appData.controller.runProtocol(p, e);
        end
        
        function onSelectedPause(obj, ~, ~)
            obj.appData.controller.pause();
        end
        
        function onSelectedStop(obj, ~, ~)
            obj.appData.controller.stop();
        end
        
        function onSetState(obj, ~, ~)
            import SymphonyUI.Models.*;
            
            enableRun = false;
            enablePause = false;
            enableStop = false;
            enableSave = false;
            status = 'Unknown';
            
            switch obj.appData.controller.state
                case ControllerState.STOPPED
                    enableRun = true;
                    enableSave = true;
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
            
            obj.view.enableRun(enableRun);
            obj.view.enablePause(enablePause);
            obj.view.enableStop(enableStop);
            obj.view.enableShouldSave(enableSave);
            obj.view.enableStatus(true);
            obj.view.setStatus(status);
        end
        
        function onSelectedPreferences(obj, ~, ~)
            p = SymphonyUI.Presenters.AppPreferencePresenter(obj.appData.appPreference);
            p.view.showDialog();
        end
        
        function onSelectedDocumentation(obj, ~, ~)
            web('https://github.com/Symphony-DAS/Symphony/wiki');
        end
        
        function onSelectedUserGroup(obj, ~, ~)
            web('https://groups.google.com/forum/#!forum/symphony-das');
        end
        
        function onSelectedAboutSymphony(obj, ~, ~)
            p = SymphonyUI.Presenters.AboutSymphonyPresenter('2.0.0-preview');
            p.view.showDialog();
        end
        
    end
    
    methods (Access = protected)
        
        function onViewClosing(obj, ~, ~)
            onViewClosing@SymphonyUI.Presenter(obj);
            obj.view.savePosition();
        end
        
    end
    
end

