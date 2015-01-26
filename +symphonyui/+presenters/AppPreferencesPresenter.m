classdef AppPreferencesPresenter < symphonyui.Presenter
    
    properties (SetAccess = private)
        preferences
    end
    
    methods
        
        function obj = AppPreferencesPresenter(preferences, view)
            import symphonyui.utilities.*;
            
            if nargin < 2
                view = symphonyui.views.AppPreferencesView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.preferences = preferences;
            
            obj.addListener(view, 'SelectedCard', @obj.onSelectedCard);
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            main = preferences;
            experiment = preferences.experimentPreferences;
            epochGroup = preferences.epochGroupPreferences;
            
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
            view.setLabelList(cellToStr(epochGroup.labelList));
            view.setRecordingList(cellToStr(epochGroup.recordingList));
            view.setDefaultKeywords(cellToStr(epochGroup.defaultKeywords));
            view.setExternalSolutionList(cellToStr(epochGroup.availableExternalSolutionList));
            view.setInternalSolutionList(cellToStr(epochGroup.availableInternalSolutionList));
            view.setOtherList(cellToStr(epochGroup.availableOtherList));
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
            labelList = strToCell(obj.view.getLabelList());
            recordingList = strToCell(obj.view.getRecordingList());
            keywords = parse(obj.view.getDefaultKeywords());
            externalSolutionList = strToCell(obj.view.getExternalSolutionList());
            internalSolutionList = strToCell(obj.view.getInternalSolutionList());
            otherList = strToCell(obj.view.getOtherList());
            
            main = obj.preferences;
            experiment = obj.preferences.experimentPreferences;
            epochGroup = obj.preferences.epochGroupPreferences;
            
            main.rigSearchPaths = rigSearchPaths;
            main.protocolSearchPaths = protocolSearchPaths;
            experiment.defaultName = name;
            experiment.defaultPurpose = purpose;
            experiment.defaultLocation = location;
            experiment.speciesList = speciesList;
            experiment.phenotypeList = phenotypeList;
            experiment.genotypeList = genotypeList;
            experiment.preparationList = preparationList;
            epochGroup.labelList = labelList;
            epochGroup.recordingList = recordingList;
            epochGroup.defaultKeywords = keywords;
            epochGroup.availableExternalSolutionList = externalSolutionList;
            epochGroup.availableInternalSolutionList = internalSolutionList;
            epochGroup.availableOtherList = otherList;
            
            obj.view.result = true;
        end
        
    end
    
end