classdef SettingsPresenter < symphonyui.ui.Presenter

    methods

        function obj = SettingsPresenter(app, view)
            if nargin < 2
                view = symphonyui.ui.views.SettingsView([]);
            end

            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.addListener(view, 'SelectedNode', @obj.onViewSelectedNode);
            obj.addListener(view, 'Ok', @obj.onViewSelectedOk);
            obj.addListener(view, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = protected)

        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.ui.Presenter(obj);
            obj.view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
        end

    end

    methods (Access = private)

        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onViewSelectedOk();
            elseif strcmp(data.Key, 'escape')
                obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedNode(obj, ~, ~)
            c = obj.view.getSelectedNode();
            obj.view.setSelectedCard(c);
        end

        function onViewSelectedOk(obj, ~, ~)
            obj.view.update();

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

            obj.view.close();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.view.close();
        end

    end

end
