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
            view.setDefaultPurpose(char(experiment.defaultPurpose));
            view.setDefaultLocation(char(experiment.defaultLocation));
            view.setRigPathList(cellToStr(experiment.rigPathList));
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
            purpose = parse(obj.view.getDefaultPurpose());
            location = parse(obj.view.getDefaultLocation());
            rigPathList = strToCell(obj.view.getRigPathList());
            speciesList = strToCell(obj.view.getSpeciesList());
            phenotypeList = strToCell(obj.view.getPhenotypeList());
            genotypeList = strToCell(obj.view.getGenotypeList());
            preparationList = strToCell(obj.view.getPreparationList());
            
            experiment = obj.appPreferences.experimentPreferences;
            experiment.defaultName = name;
            experiment.defaultPurpose = purpose;
            experiment.defaultLocation = location;
            experiment.rigPathList = rigPathList;
            experiment.speciesList = speciesList;
            experiment.phenotypeList = phenotypeList;
            experiment.genotypeList = genotypeList;
            experiment.preparationList = preparationList;
            
            obj.view.result = true;
        end
        
    end
    
end