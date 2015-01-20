classdef AppPreferencesPresenter < SymphonyUI.Presenter
    
    properties (SetAccess = private)
        appPreferences
    end
    
    methods
        
        function obj = AppPreferencesPresenter(preferences, view)
            import SymphonyUI.Utilities.*;
            
            if nargin < 2
                view = SymphonyUI.Views.AppPreferencesView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            
            obj.appPreferences = preferences;
            
            obj.addListener(view, 'SelectedCard', @obj.onSelectedCard);
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            experiment = preferences.experimentPreferences;
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            view.setDefaultName(char(experiment.defaultName));
            view.setDefaultLocation(char(experiment.defaultLocation));
            view.setDefaultPurpose(char(experiment.defaultPurpose));
            view.setSpeciesList(cellToStr(experiment.speciesList));
            view.setPhenotypeList(cellToStr(experiment.phenotypeList));
            view.setGenotypeList(cellToStr(experiment.genotypeList));
            view.setPreparationList(cellToStr(experiment.preparationList));
        end
        
    end
    
    methods (Access = private)
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedOk();
            elseif strcmp(data.Key, 'escape')
                obj.view.close();
            end
        end
        
        function onSelectedCard(obj, ~, ~)
            c = obj.view.getCard();
            obj.view.setCard(c);
        end
        
        function onSelectedOk(obj, ~, ~)     
            import SymphonyUI.Utilities.*;
            
            function out = parse(in)
                if ~isempty(in) && in(1) == '@'
                    in = str2func(in);
                end
                out = in;
            end
            
            name = parse(obj.view.getDefaultName());
            location = parse(obj.view.getDefaultLocation());
            purpose = parse(obj.view.getDefaultPurpose());
            speciesList = strToCell(obj.view.getSpeciesList());
            
            experiment = obj.appPreferences.experimentPreferences;
            experiment.defaultName = name;
            experiment.defaultLocation = location;
            experiment.defaultPurpose = purpose;
            experiment.speciesList = speciesList;
            
            obj.view.result = true;
        end
        
    end
    
end