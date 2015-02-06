classdef NewExperimentPresenter < symphonyui.Presenter
    
    properties (SetAccess = private)
        appData
    end
    
    methods
        
        function obj = NewExperimentPresenter(appData, view)
            if nargin < 2
                view = symphonyui.views.NewExperimentView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.appData = appData;
            
            obj.addListener(view, 'BrowseLocation', @obj.onSelectedBrowseLocation);
            obj.addListener(view, 'Open', @obj.onSelectedOpen);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.Presenter(obj);
            
            preferences = obj.appData.experimentPreferences;
            obj.view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            obj.view.setName(preferences.defaultName());
            obj.view.setPurpose(preferences.defaultPurpose());
            obj.view.setLocation(preferences.defaultLocation());
            obj.view.setSpeciesList(preferences.speciesList());
            obj.view.setPhenotypeList(preferences.phenotypeList());
            obj.view.setGenotypeList(preferences.genotypeList());
            obj.view.setPreparationList(preferences.preparationList());
        end
        
    end
    
    methods (Access = private)
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedOpen();
            elseif strcmp(data.Key, 'escape')
                obj.view.close();
            end
        end
        
        function onSelectedBrowseLocation(obj, ~, ~)
            location = uigetdir(pwd, 'Experiment Location');
            if location ~= 0
                obj.view.setLocation(location);
            end
        end
        
        function onSelectedOpen(obj, ~, ~)
            drawnow();
            
            name = obj.view.getName();            
            location = obj.view.getLocation();
            purpose = obj.view.getPurpose();
            source = [];
            
            path = fullfile(location, name);
            
            experiment = symphonyui.models.Experiment(path, purpose, source);
            experiment.open();
            
            obj.appData.setExperiment(experiment);
            
            obj.view.result = true;
        end
        
    end
    
end
