classdef NewExperimentPresenter < symphonyui.Presenter
    
    properties (SetAccess = private)
        experiment
    end
    
    methods
        
        function obj = NewExperimentPresenter(preferences, view)
            import symphonyui.utilities.*;
            
            if nargin < 2
                view = symphonyui.views.NewExperimentView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.addListener(view, 'BrowseLocation', @obj.onSelectedBrowseLocation);
            obj.addListener(view, 'Open', @obj.onSelectedOpen);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            view.setName(preferences.defaultName());
            view.setPurpose(preferences.defaultPurpose());
            view.setLocation(preferences.defaultLocation());
            view.setSpeciesList(preferences.speciesList());
            view.setPhenotypeList(preferences.phenotypeList());
            view.setGenotypeList(preferences.genotypeList());
            view.setPreparationList(preferences.preparationList());
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
