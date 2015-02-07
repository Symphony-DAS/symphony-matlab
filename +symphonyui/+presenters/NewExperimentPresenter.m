classdef NewExperimentPresenter < symphonyui.Presenter
    
    properties (SetAccess = private)
        manager
    end
    
    methods
        
        function obj = NewExperimentPresenter(manager, view)
            if nargin < 2
                view = symphonyui.views.NewExperimentView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.manager = manager;
            
            obj.addListener(view, 'BrowseLocation', @obj.onSelectedBrowseLocation);
            obj.addListener(view, 'Open', @obj.onSelectedOpen);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.Presenter(obj);
            
            preferences = obj.manager.preferences.experimentPreferences;
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
            
            try
                obj.manager.openExperiment(path, purpose, source);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.view.result = true;
        end
        
    end
    
end
