classdef SettingsView < symphonyui.View
    
    events
        SelectedCard
        Ok
        Cancel
    end
    
    properties (Access = private)
        cardList
        cardPanel
        generalCard
        experimentsCard
        epochGroupsCard
        okButton
        cancelButton
    end
    
    methods
        
        function obj = SettingsView(parent)
            obj = obj@symphonyui.View(parent);
        end
        
        function createUI(obj)
            import symphonyui.util.*;
            import symphonyui.util.ui.*;
            
            set(obj.figureHandle, 'Name', 'Settings');
            set(obj.figureHandle, 'Position', screenCenter(467, 356));
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            preferencesLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.cardList = uicontrol( ...
                'Parent', preferencesLayout, ...
                'Style', 'list', ...
                'String', {'General', 'Experiments', 'Epoch Groups', 'Sources'}, ...
                'Callback', @(h,d)notify(obj, 'SelectedCard'));
            
            obj.cardPanel = uix.CardPanel( ...
                'Parent', preferencesLayout);
            
            % General card.
            generalLabelSize = 120;
            generalLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            obj.generalCard.rigSearchPathsField = createLabeledTextField(generalLayout, 'Rig search paths:', [generalLabelSize -1]);
            obj.generalCard.protocolSearchPathsField = createLabeledTextField(generalLayout, 'Protocol search paths:', [generalLabelSize -1]);
            set(generalLayout, 'Sizes', [25 25]);
            
            % Experiments card.
            experimentsLabelSize = 100;
            experimentsLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            obj.experimentsCard.defaultNameField = createLabeledTextField(experimentsLayout, 'Default name:', [experimentsLabelSize -1]);
            obj.experimentsCard.defaultPurposeField = createLabeledTextField(experimentsLayout, 'Default purpose:', [experimentsLabelSize -1]);
            obj.experimentsCard.defaultLocationField = createLabeledTextField(experimentsLayout, 'Default location:', [experimentsLabelSize -1]);
            set(experimentsLayout, 'Sizes', [25 25 25]);
            
            % Epoch group card.
            epochGroupsLabelSize = 115;
            epochGroupsLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            obj.epochGroupsCard.labelListField = createLabeledTextField(epochGroupsLayout, 'Label list:', [epochGroupsLabelSize -1]);
            obj.epochGroupsCard.recordingListField = createLabeledTextField(epochGroupsLayout, 'Recording list:', [epochGroupsLabelSize -1]);
            obj.epochGroupsCard.defaultKeywordsField = createLabeledTextField(epochGroupsLayout, 'Default keywords:', [epochGroupsLabelSize -1]);
            obj.epochGroupsCard.externalSolutionListField = createLabeledTextField(epochGroupsLayout, 'External solution list:', [epochGroupsLabelSize -1]);
            obj.epochGroupsCard.internalSolutionListField = createLabeledTextField(epochGroupsLayout, 'Internal solution list:', [epochGroupsLabelSize -1]);
            obj.epochGroupsCard.otherListField = createLabeledTextField(epochGroupsLayout, 'Other list:', [epochGroupsLabelSize -1]);
            set(epochGroupsLayout, 'Sizes', [25 25 25 25 25 25]);
            
            % Sources card.
            sourcesLabelSize = 100;
            sourcesLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            
            set(obj.cardPanel, 'Selection', 1);
            
            set(preferencesLayout, 'Sizes', [110 -1]);
            
            % Ok/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);
            
            set(mainLayout, 'Sizes', [-1 25]);
            
            % Set OK button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end
        
        function c = getCard(obj)
            c = symphonyui.util.ui.getSelectedValue(obj.cardList);
        end
        
        function setCard(obj, c)
            list = get(obj.cardList, 'String');
            selection = find(strcmp(list, c));
            set(obj.cardPanel, 'Selection', selection);
            symphonyui.util.ui.setSelectedValue(obj.cardList, c);
        end
        
        function p = getRigSearchPaths(obj)
            p = get(obj.generalCard.rigSearchPathsField, 'String');
        end
        
        function setRigSearchPaths(obj, p)
            set(obj.generalCard.rigSearchPathsField, 'String', p);
        end
        
        function p = getProtocolSearchPaths(obj)
            p = get(obj.generalCard.protocolSearchPathsField, 'String');
        end
        
        function setProtocolSearchPaths(obj, p)
            set(obj.generalCard.protocolSearchPathsField, 'String', p);
        end
        
        function n = getDefaultName(obj)
            n = get(obj.experimentsCard.defaultNameField, 'String');
        end
        
        function setDefaultName(obj, n)
            set(obj.experimentsCard.defaultNameField, 'String', n);
        end
        
        function p = getDefaultPurpose(obj)
            p = get(obj.experimentsCard.defaultPurposeField, 'String');
        end
        
        function setDefaultPurpose(obj, p)
            set(obj.experimentsCard.defaultPurposeField, 'String', p);
        end
        
        function l = getDefaultLocation(obj)
            l = get(obj.experimentsCard.defaultLocationField, 'String');
        end
        
        function setDefaultLocation(obj, l)
            set(obj.experimentsCard.defaultLocationField, 'String', l);
        end
        
        function s = getSpeciesList(obj)
            s = get(obj.experimentsCard.speciesListField, 'String');
        end
        
        function setSpeciesList(obj, s)
            set(obj.experimentsCard.speciesListField, 'String', s);
        end
        
        function p = getPhenotypeList(obj)
            p = get(obj.experimentsCard.phenotypeListField, 'String');
        end
        
        function setPhenotypeList(obj, p)
            set(obj.experimentsCard.phenotypeListField, 'String', p);
        end
        
        function g = getGenotypeList(obj)
            g = get(obj.experimentsCard.genotypeListField, 'String');
        end
        
        function setGenotypeList(obj, g)
            set(obj.experimentsCard.genotypeListField, 'String', g);
        end
        
        function p = getPreparationList(obj)
            p = get(obj.experimentsCard.preparationListField, 'String');
        end
        
        function setPreparationList(obj, p)
            set(obj.experimentsCard.preparationListField, 'String', p);
        end
        
        function l = getLabelList(obj)
            l = get(obj.epochGroupsCard.labelListField, 'String');
        end
        
        function setLabelList(obj, s)
            set(obj.epochGroupsCard.labelListField, 'String', s);
        end
        
        function r = getRecordingList(obj)
            r = get(obj.epochGroupsCard.recordingListField, 'String');
        end
        
        function setRecordingList(obj, r)
            set(obj.epochGroupsCard.recordingListField, 'String', r);
        end
        
        function k = getDefaultKeywords(obj)
            k = get(obj.epochGroupsCard.defaultKeywordsField, 'String');
        end
        
        function setDefaultKeywords(obj, k)
            set(obj.epochGroupsCard.defaultKeywordsField, 'String', k);
        end
        
        function s = getExternalSolutionList(obj)
            s = get(obj.epochGroupsCard.externalSolutionListField, 'String');
        end
        
        function setExternalSolutionList(obj, s)
            set(obj.epochGroupsCard.externalSolutionListField, 'String', s);
        end
        
        function s = getInternalSolutionList(obj)
            s = get(obj.epochGroupsCard.internalSolutionListField, 'String');
        end
        
        function setInternalSolutionList(obj, s)
            set(obj.epochGroupsCard.internalSolutionListField, 'String', s);
        end
        
        function o = getOtherList(obj)
            o = get(obj.epochGroupsCard.otherListField, 'String');
        end
        
        function setOtherList(obj, o)
            set(obj.epochGroupsCard.otherListField, 'String', o);
        end
        
    end
    
end