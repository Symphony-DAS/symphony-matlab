classdef ControllerPresenter < SymphonyUI.Presenter
    
    properties
        controller
        parametersPresenter
    end
    
    methods
        
        function c = get.controller(obj)
            c = obj.view.controller;
        end
        
        function viewDidLoad(obj)
            obj.view.centerOnScreen(274, 120);
            viewDidLoad@SymphonyUI.Presenter(obj);            
        end
        
        function onSelectedNewExperiment(obj, ~, ~)
            v = SymphonyUI.Views.NewExperimentView();
            v.show();
            if ~isempty(v.experiment)
                obj.controller.experiment = v.experiment;
                obj.onSelectedBeginEpochGroup();
            end
        end
        
        function onSelectedCloseExperiment(obj, ~, ~)
            obj.controller.experiment = [];
            obj.controller.protocol = [];
        end
        
        function onSelectedBeginEpochGroup(obj, ~, ~)
            v = SymphonyUI.Views.BeginEpochGroupView();
            v.show();
            if ~isempty(v.epochGroup)
                obj.controller.experiment.epochGroup = v.epochGroup;
            end
        end
        
        function onSelectedEndEpochGroup(obj, ~, ~)
            obj.controller.experiment.epochGroup = obj.controller.experiment.epochGroup.parent;
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
            if ~isempty(p)
                obj.controller.protocol = SymphonyUI.Models.Protocol();
            end
        end
        
        function onSelectedRunProtocol(obj, ~, ~)
            obj.controller.run();
        end
        
        function onSelectedPauseProtocol(obj, ~, ~)
            obj.controller.pause();
        end
        
        function onSelectedStopProtocol(obj, ~, ~)
            obj.controller.stop();
        end
        
        function onSelectedProtocolParameters(obj, ~, ~)
            if isempty(obj.parametersPresenter) || obj.parametersPresenter.view.isClosed
                v = SymphonyUI.Views.ProtocolParametersView();
                obj.parametersPresenter = v.presenter;
            end
            
            obj.parametersPresenter.view.show();
        end
        
        function onSelectedSaveCheckbox(obj, ~, ~)
            if obj.view.getSaveCheckboxValue()
                obj.view.setSaveCheckboxColor('black');
            else
                obj.view.setSaveCheckboxColor('red');
            end
        end
        
        function onSelectedClose(obj, ~, ~)
            if ~isempty(obj.parametersPresenter)
                obj.parametersPresenter.onSelectedClose();
            end
            
            onSelectedClose@SymphonyUI.Presenter(obj);
        end
        
    end
    
end

