classdef NewExperimentPresenter < SymphonyUI.Presenter
    
    properties (SetAccess = private)
        experiment
    end
    
    methods
        
        function obj = NewExperimentPresenter(view)
            if nargin < 1
                view = SymphonyUI.Views.NewExperimentView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            
            obj.addListener(view, 'BrowseLocation', @obj.onSelectedBrowseLocation);
            obj.addListener(view, 'Open', @obj.onSelectedOpen);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
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
            location = uigetdir('', 'Experiment Location');
            if location ~= 0
                obj.view.setLocation(location);
            end
        end
        
        function onSelectedOpen(obj, ~, ~)
            name = obj.view.getName();            
            location = obj.view.getLocation();
            rig = obj.view.getRig();
            purpose = obj.view.getPurpose();
            source = [];
            
            path = fullfile(location, name);
            
            obj.experiment = SymphonyUI.Models.Experiment(path, rig, purpose, source);
            obj.experiment.open();
            
            obj.view.result = true;
        end
        
    end
    
end

