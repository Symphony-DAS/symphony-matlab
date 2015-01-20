classdef AppPreferencesView < SymphonyUI.View
    
    events
        SelectedCard
        Ok
        Cancel
    end
    
    properties (Access = private)
        cardList
        cardPanel
        experimentCard
        okButton
        cancelButton
    end
    
    methods
        
        function obj = AppPreferencesView(parent)
            obj = obj@SymphonyUI.View(parent);
        end
        
        function createUI(obj)
            import SymphonyUI.Utilities.*;
            import SymphonyUI.Utilities.UI.*;
            
            set(obj.figureHandle, 'Name', 'Preferences');
            set(obj.figureHandle, 'Position', screenCenter(454, 356));
            
            labelSize = 100;
            panelLabelSize = 87;
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
                'String', {'Experiment', 'Epoch Group', 'Acquisition'}, ...
                'Callback', @(h,d)notify(obj, 'SelectedCard'));
            
            obj.cardPanel = uix.CardPanel( ...
                'Parent', preferencesLayout);
            
            % Experiment card.
            experimentLayout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Spacing', 7);
            obj.experimentCard.defaultNameField = createLabeledTextField(experimentLayout, 'Default name:', [labelSize -1]);
            obj.experimentCard.defaultLocationField = createLabeledTextField(experimentLayout, 'Default location:', [labelSize -1]);
            obj.experimentCard.defaultPurposeField = createLabeledTextField(experimentLayout, 'Default purpose:', [labelSize -1]);
            
            animalPanel = uix.Panel( ...
                'Parent', experimentLayout, ...
                'Title', 'Animal', ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            animalLayout = uiextras.VBox( ...
                'Parent', animalPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            obj.experimentCard.speciesListField = createLabeledTextField(animalLayout, 'Species list:', [panelLabelSize -1]);
            obj.experimentCard.phenotypeListField = createLabeledTextField(animalLayout, 'Phenotype list:', [panelLabelSize -1]);
            obj.experimentCard.genotypeListField = createLabeledTextField(animalLayout, 'Genotype list:', [panelLabelSize -1]);
            set(animalLayout, 'Sizes', [25 25 25]);
            
            tissuePanel = uix.Panel( ...
                'Parent', experimentLayout, ...
                'Title', 'Tissue', ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            tissueLayout = uiextras.VBox( ...
                'Parent', tissuePanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            obj.experimentCard.preparationListField = createLabeledTextField(tissueLayout, 'Preparation list:', [panelLabelSize -1]);
            set(tissueLayout, 'Sizes', [25]);
            
            set(experimentLayout, 'Sizes', [25 25 25 132 68]);
            
            % Epoch group card.
            layout = uiextras.VBox( ...
                'Parent', obj.cardPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            % Acquisition card.
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
            c = SymphonyUI.Utilities.UI.getSelectedValue(obj.cardList);
        end
        
        function setCard(obj, c)
            list = get(obj.cardList, 'String');
            selection = find(strcmp(list, c));
            set(obj.cardPanel, 'Selection', selection);
            SymphonyUI.Utilities.UI.setSelectedValue(obj.cardList, c);
        end
        
        function n = getDefaultName(obj)
            n = get(obj.experimentCard.defaultNameField, 'String');
        end
        
        function setDefaultName(obj, n)
            set(obj.experimentCard.defaultNameField, 'String', n);
        end
        
        function l = getDefaultLocation(obj)
            l = get(obj.experimentCard.defaultLocationField, 'String');
        end
        
        function setDefaultLocation(obj, l)
            set(obj.experimentCard.defaultLocationField, 'String', l);
        end
        
        function p = getDefaultPurpose(obj)
            p = get(obj.experimentCard.defaultPurposeField, 'String');
        end
        
        function setDefaultPurpose(obj, p)
            set(obj.experimentCard.defaultPurposeField, 'String', p);
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