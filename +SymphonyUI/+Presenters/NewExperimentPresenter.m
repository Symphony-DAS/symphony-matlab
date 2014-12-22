classdef NewExperimentPresenter < SymphonyUI.Presenter
    
    properties
    end
    
    methods
        
        function viewDidLoad(obj)
            obj.view.centerOnScreen(518, 276);           
        end
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedOpen();
            elseif strcmp(data.Key, 'escape')
                obj.onSelectedClose();
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
            if isempty(name)
                errordlg('Name cannot be empty');
                return;
            end
            
            location = obj.view.getLocation();
            if isempty(location)
                errordlg('Location cannot be empty');
                return;
            end
            if ~exist(location, 'dir')
                errordlg('Location does not exist');
                return;
            end
            
            rig = obj.view.getRig();
            if isempty(rig)
                errordlg('Rig cannot be empty');
                return;
            end
            
            purpose = obj.view.getPurpose();
            
            path = fullfile(location, name);            
            
            obj.view.experiment = SymphonyUI.Models.Experiment(path, rig, purpose);
            obj.view.close();
        end
        
    end
    
end

