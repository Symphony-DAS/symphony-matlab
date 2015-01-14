classdef NewEpochGroupPresenter < SymphonyUI.Presenter
    
    properties (SetAccess = private)
        experiment
    end
    
    methods
        
        function obj = NewEpochGroupPresenter(experiment, epochGroupPreference, view)
            if nargin < 2
                epochGroupPreference = SymphonyUI.Configurations.epochGroupPreference();
                epochGroupPreference.setToDefaults();
            end
            if nargin < 3
                view = SymphonyUI.Views.NewEpochGroupView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            
            obj.experiment = experiment;
            
            obj.addListener(view, 'AddExternalSolution', @obj.onSelectedAddExternalSolution);
            obj.addListener(view, 'RemoveExternalSolution', @obj.onSelectedRemoveExternalSolution);
            obj.addListener(view, 'AddInternalSolution', @obj.onSelectedAddInternalSolution);
            obj.addListener(view, 'RemoveInternalSolution', @obj.onSelectedRemoveInternalSolution);
            obj.addListener(view, 'AddOther', @obj.onSelectedAddOther);
            obj.addListener(view, 'RemoveOther', @obj.onSelectedRemoveOther);
            obj.addListener(view, 'Begin', @obj.onSelectedBegin);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            view.setLabels(epochGroupPreference.labels);
            view.setRecordings(epochGroupPreference.recordingTypes);
            view.setAvailableExternalSolutions(epochGroupPreference.availableExternalSolutions);
            view.setAvailableInternalSolutions(epochGroupPreference.availableInternalSolutions);
            view.setAvailableOthers(epochGroupPreference.availableOthers);
        end
        
    end
    
    methods (Access = private)
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedBegin();
            elseif strcmp(data.Key, 'escape')
                obj.view.close();
            end
        end
        
        function onSelectedAddExternalSolution(obj, ~, ~)
            c = obj.view.getAvailableExternalSolution();
            if ~ischar(c)
                return;
            end
            added = obj.view.getAddedExternalSolutions();
            if any(ismember(added, c))
                return;
            end
            obj.view.setAddedExternalSolutions([added;{c}]);
        end
        
        function onSelectedRemoveExternalSolution(obj, ~, ~)
            c = obj.view.getAddedExternalSolution();
            if ~ischar(c)
                return;
            end
            added = obj.view.getAddedExternalSolutions();
            index = ismember(added, c);
            added(index) = [];
            obj.view.setAddedExternalSolutions(added);
        end
        
        function onSelectedAddInternalSolution(obj, ~, ~)
            c = obj.view.getAvailableInternalSolution();
            if ~ischar(c)
                return;
            end
            added = obj.view.getAddedInternalSolutions();
            if any(ismember(added, c))
                return;
            end
            obj.view.setAddedInternalSolutions([added;{c}]);
        end
        
        function onSelectedRemoveInternalSolution(obj, ~, ~)
            c = obj.view.getAddedInternalSolution();
            if ~ischar(c)
                return;
            end
            added = obj.view.getAddedInternalSolutions();
            index = ismember(added, c);
            added(index) = [];
            obj.view.setAddedInternalSolutions(added);
        end
        
        function onSelectedAddOther(obj, ~, ~)
            c = obj.view.getAvailableOther();
            if ~ischar(c)
                return;
            end
            added = obj.view.getAddedOthers();
            if any(ismember(added, c))
                return;
            end
            obj.view.setAddedOthers([added;{c}]);
        end
        
        function onSelectedRemoveOther(obj, ~, ~)
            c = obj.view.getAddedOther();
            if ~ischar(c)
                return;
            end
            added = obj.view.getAddedOthers();
            index = ismember(added, c);
            added(index) = [];
            obj.view.setAddedOthers(added);
        end
        
        function onSelectedBegin(obj, ~, ~)
            label = obj.view.getLabel();
            recording = obj.view.getRecording();
            keywords = obj.view.getKeywords();
            source = obj.view.getSource();
            
            attributes = [];
            
            obj.experiment.beginEpochGroup(label, source, keywords, attributes);
            
            obj.view.result = true;
        end
        
    end
    
end

