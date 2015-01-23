classdef NewExperimentPresenter < SymphonyUI.Presenter
    
    properties (SetAccess = private)
        experiment
    end
    
    methods
        
        function obj = NewExperimentPresenter(preferences, view)
            import SymphonyUI.Utilities.*;
            
            if nargin < 2
                view = SymphonyUI.Views.NewExperimentView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            
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
        
        function onSelectedOpen(obj, ~, ~)
            name = obj.view.getName();            
            location = obj.view.getLocation();
            purpose = obj.view.getPurpose();
            source = [];
            
            path = fullfile(location, name);
            
            obj.experiment = SymphonyUI.Models.Experiment(path, purpose, source);
            obj.experiment.open();
            
            obj.view.result = true;
        end
        
    end
    
end
