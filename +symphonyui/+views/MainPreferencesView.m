classdef MainPreferencesView < symphonyui.View
    
    events
        SelectedCard
        Ok
        Cancel
    end
    
    properties (Access = private)
        cardList
        cardPanel
        mainCard
        experimentCard
        okButton
        cancelButton
    end
    
    methods
        
        function obj = MainPreferencesView(parent)
            obj = obj@symphonyui.View(parent);
        end
        
        function createUI(obj)
            import symphonyui.utilities.*;
            import symphonyui.utilities.ui.*;
            
            set(obj.figureHandle, 'Name', 'Preferences');
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
                'String', {'Main', 'Experiment', 'Epoch Group'}, ...
                'Callback', @(h,d)notify(obj, 'SelectedCard'));
            
            obj.cardPanel = uix.CardPanel( ...
                'Parent', preferencesLayout);
            
            % Main card.
            mainLabelSize = 120;
            mainCardLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            obj.mainCard.rigSearchPathsField = createLabeledTextField(mainCardLayout, 'Rig search paths:', [mainLabelSize -1]);
            obj.mainCard.protocolSearchPathsField = createLabeledTextField(mainCardLayout, 'Protocol search paths:', [mainLabelSize -1]);
            
            set(mainCardLayout, 'Sizes', [25 25]);
            
            % Experiment card.
            experimentLabelSize = 100;
            experimentPanelLabelSize = 87;
            experimentCardLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            obj.experimentCard.defaultNameField = createLabeledTextField(experimentCardLayout, 'Default name:', [experimentLabelSize -1]);
            obj.experimentCard.defaultPurposeField = createLabeledTextField(experimentCardLayout, 'Default purpose:', [experimentLabelSize -1]);
            obj.experimentCard.defaultLocationField = createLabeledTextField(experimentCardLayout, 'Default location:', [experimentLabelSize -1]);
            
            animalPanel = uix.Panel( ...
                'Parent', experimentCardLayout, ...
                'Title', 'Animal', ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            animalLayout = uiextras.VBox( ...
                'Parent', animalPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            obj.experimentCard.speciesListField = createLabeledTextField(animalLayout, 'Species list:', [experimentPanelLabelSize -1]);
            obj.experimentCard.phenotypeListField = createLabeledTextField(animalLayout, 'Phenotype list:', [experimentPanelLabelSize -1]);
            obj.experimentCard.genotypeListField = createLabeledTextField(animalLayout, 'Genotype list:', [experimentPanelLabelSize -1]);
            set(animalLayout, 'Sizes', [25 25 25]);
            
            tissuePanel = uix.Panel( ...
                'Parent', experimentCardLayout, ...
                'Title', 'Tissue', ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            tissueLayout = uiextras.VBox( ...
                'Parent', tissuePanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            obj.experimentCard.preparationListField = createLabeledTextField(tissueLayout, 'Preparation list:', [experimentPanelLabelSize -1]);
            set(tissueLayout, 'Sizes', [25]);
            
            set(experimentCardLayout, 'Sizes', [25 25 25 132 68]);
            
            % Epoch group card.
            layout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Padding', 11, ...
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
            c = symphonyui.utilities.ui.getSelectedValue(obj.cardList);
        end
        
        function setCard(obj, c)
            list = get(obj.cardList, 'String');
            selection = find(strcmp(list, c));
            set(obj.cardPanel, 'Selection', selection);
            symphonyui.utilities.ui.setSelectedValue(obj.cardList, c);
        end
        
        function p = getRigSearchPaths(obj)
            p = get(obj.mainCard.rigSearchPathsField, 'String');
        end
        
        function setRigSearchPaths(obj, p)
            set(obj.mainCard.rigSearchPathsField, 'String', p);
        end
        
        function p = getProtocolSearchPaths(obj)
            p = get(obj.mainCard.protocolSearchPathsField, 'String');
        end
        
        function setProtocolSearchPaths(obj, p)
            set(obj.mainCard.protocolSearchPathsField, 'String', p);
        end
        
        function n = getDefaultName(obj)
            n = get(obj.experimentCard.defaultNameField, 'String');
        end
        
        function setDefaultName(obj, n)
            set(obj.experimentCard.defaultNameField, 'String', n);
        end
        
        function p = getDefaultPurpose(obj)
            p = get(obj.experimentCard.defaultPurposeField, 'String');
        end
        
        function setDefaultPurpose(obj, p)
            set(obj.experimentCard.defaultPurposeField, 'String', p);
        end
        
        function l = getDefaultLocation(obj)
            l = get(obj.experimentCard.defaultLocationField, 'String');
        end
        
        function setDefaultLocation(obj, l)
            set(obj.experimentCard.defaultLocationField, 'String', l);
        end
        
        function s = getSpeciesList(obj)
            s = get(obj.experimentCard.speciesListField, 'String');
        end
        
        function setSpeciesList(obj, s)
            set(obj.experimentCard.speciesListField, 'String', s);
        end
        
        function p = getPhenotypeList(obj)
            p = get(obj.experimentCard.phenotypeListField, 'String');
        end
        
        function setPhenotypeList(obj, p)
            set(obj.experimentCard.phenotypeListField, 'String', p);
        end
        
        function g = getGenotypeList(obj)
            g = get(obj.experimentCard.genotypeListField, 'String');
        end
        
        function setGenotypeList(obj, g)
            set(obj.experimentCard.genotypeListField, 'String', g);
        end
        
        function p = getPreparationList(obj)
            p = get(obj.experimentCard.preparationListField, 'String');
        end
        
        function setPreparationList(obj, p)
            set(obj.experimentCard.preparationListField, 'String', p);
        end
        
    end
    
end