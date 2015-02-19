classdef SettingsPresenter < symphonyui.Presenter
    
    methods
        
        function obj = SettingsPresenter(view)            
            if nargin < 2
                view = symphonyui.views.SettingsView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.addListener(view, 'SelectedCard', @obj.onSelectedCard);
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)
            import symphonyui.app.Settings;
            
            onViewShown@symphonyui.Presenter(obj);
            
            gen = Settings.general;
            
            obj.view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            obj.view.setRigSearchPaths(gen.rigSearchPaths);
            obj.view.setProtocolSearchPaths(gen.protocolSearchPaths);
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
            import symphonyui.util.*;
            drawnow();
            
%             function out = parse(in)
%                 if ~isempty(in) && in(1) == '@'
%                     in = str2func(in);
%                 end
%                 out = in;
%             end
%             
%             rigSearchPaths = strToCell(obj.view.getRigSearchPaths);
%             protocolSearchPaths = strToCell(obj.view.getProtocolSearchPaths);
%             name = parse(obj.view.getDefaultName());
%             purpose = parse(obj.view.getDefaultPurpose());
%             location = parse(obj.view.getDefaultLocation());
%             speciesList = strToCell(obj.view.getSpeciesList());
%             phenotypeList = strToCell(obj.view.getPhenotypeList());
%             genotypeList = strToCell(obj.view.getGenotypeList());
%             preparationList = strToCell(obj.view.getPreparationList());
%             labelList = strToCell(obj.view.getLabelList());
%             recordingList = strToCell(obj.view.getRecordingList());
%             keywords = parse(obj.view.getDefaultKeywords());
%             externalSolutionList = strToCell(obj.view.getExternalSolutionList());
%             internalSolutionList = strToCell(obj.view.getInternalSolutionList());
%             otherList = strToCell(obj.view.getOtherList());
%                         
%             rig = obj.settings.rigSettings;
%             protocol = obj.settings.protocolSettings;
%             experiment = obj.settings.experimentSettings;
%             epochGroup = obj.settings.epochGroupSettings;
%             
%             rig.searchPaths = rigSearchPaths;
%             protocol.searchPaths = protocolSearchPaths;
%             experiment.defaultName = name;
%             experiment.defaultPurpose = purpose;
%             experiment.defaultLocation = location;
%             experiment.speciesList = speciesList;
%             experiment.phenotypeList = phenotypeList;
%             experiment.genotypeList = genotypeList;
%             experiment.preparationList = preparationList;
%             epochGroup.labelList = labelList;
%             epochGroup.recordingList = recordingList;
%             epochGroup.defaultKeywords = keywords;
%             epochGroup.availableExternalSolutionList = externalSolutionList;
%             epochGroup.availableInternalSolutionList = internalSolutionList;
%             epochGroup.availableOtherList = otherList;
            
            obj.view.result = true;
        end
        
    end
    
end