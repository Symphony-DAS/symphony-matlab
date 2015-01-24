classdef MainPreferencesPresenter < symphonyui.Presenter
    
    properties (SetAccess = private)
        preferences
    end
    
    methods
        
        function obj = MainPreferencesPresenter(preferences, view)
            import symphonyui.utilities.*;
            
            if nargin < 2
                view = symphonyui.views.MainPreferencesView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.preferences = preferences;
            
            obj.addListener(view, 'SelectedCard', @obj.onSelectedCard);
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            main = preferences;
            experiment = preferences.experimentPreferences;
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            view.setRigSearchPaths(cellToStr(main.rigSearchPaths));
            view.setProtocolSearchPaths(cellToStr(main.protocolSearchPaths));
            view.setDefaultName(char(experiment.defaultName));
            view.setDefaultPurpose(char(experiment.defaultPurpose));
            view.setDefaultLocation(char(experiment.defaultLocation));
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
            import symphonyui.utilities.*;
            
            function out = parse(in)
                if ~isempty(in) && in(1) == '@'
                    in = str2func(in);
                end
                out = in;
            end
            
            rigSearchPaths = strToCell(obj.view.getRigSearchPaths);
            protocolSearchPaths = strToCell(obj.view.getProtocolSearchPaths);
            name = parse(obj.view.getDefaultName());
            purpose = parse(obj.view.getDefaultPurpose());
            location = parse(obj.view.getDefaultLocation());
            speciesList = strToCell(obj.view.getSpeciesList());
            phenotypeList = strToCell(obj.view.getPhenotypeList());
            genotypeList = strToCell(obj.view.getGenotypeList());
            preparationList = strToCell(obj.view.getPreparationList());
            
            main = obj.preferences;
            experiment = obj.preferences.experimentPreferences;
            
            main.rigSearchPaths = rigSearchPaths;
            main.protocolSearchPaths = protocolSearchPaths;
            experiment.defaultName = name;
            experiment.defaultPurpose = purpose;
            experiment.defaultLocation = location;
            experiment.speciesList = speciesList;
            experiment.phenotypeList = phenotypeList;
            experiment.genotypeList = genotypeList;
            experiment.preparationList = preparationList;
            
            obj.view.result = true;
        end
        
    end
    
end