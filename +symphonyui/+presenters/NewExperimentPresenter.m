classdef NewExperimentPresenter < symphonyui.Presenter
    
    properties (SetAccess = private)
        experiment
        preferences
    end
    
    methods
        
        function obj = NewExperimentPresenter(preferences, view)
            if nargin < 2
                view = symphonyui.views.NewExperimentView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.preferences = preferences;
            
            obj.addListener(view, 'BrowseLocation', @obj.onSelectedBrowseLocation);
            obj.addListener(view, 'Open', @obj.onSelectedOpen);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.Presenter(obj);
            
            obj.view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            obj.view.setName(obj.preferences.defaultName());
            obj.view.setPurpose(obj.preferences.defaultPurpose());
            obj.view.setLocation(obj.preferences.defaultLocation());
            obj.view.setSpeciesList(obj.preferences.speciesList());
            obj.view.setPhenotypeList(obj.preferences.phenotypeList());
            obj.view.setGenotypeList(obj.preferences.genotypeList());
            obj.view.setPreparationList(obj.preferences.preparationList());
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
            
            obj.experiment = symphonyui.models.Experiment(path, purpose, source);
            obj.experiment.open();
            
            obj.view.result = true;
        end
        
    end
    
end
