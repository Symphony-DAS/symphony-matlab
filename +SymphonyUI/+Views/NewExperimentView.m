classdef NewExperimentView < SymphonyUI.View
    
    events
        BrowseLocation
        Open
        Cancel
    end
    
    properties (Access = private)
        nameField
        locationField
        browseLocationButton
        purposeField
        rigDropDown
        speciesDropDown
        phenotypeDropDown
        genotypeDropDown
        preparationDropDown
        openButton
        cancelButton
    end
    
    methods
        
        function obj = NewExperimentView(parent)
            obj = obj@SymphonyUI.View(parent);
        end
        
        function createUI(obj)
            import SymphonyUI.Utilities.*;
            import SymphonyUI.Utilities.UI.*;
            
            set(obj.figureHandle, 'Name', 'New Experiment');
            set(obj.figureHandle, 'Position', screenCenter(330, 389));
            
            labelSize = 58;
            panelLabelSize = 72;
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            parametersLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.nameField = createLabeledTextField(parametersLayout, 'Name:', [labelSize -1]);
            obj.purposeField = createLabeledTextField(parametersLayout, 'Purpose:', [labelSize -1]);
            obj.rigDropDown = createLabeledDropDownMenu(parametersLayout, 'Rig:', [labelSize -1]);
            [obj.locationField, l] = createLabeledTextField(parametersLayout, 'Location:', [labelSize -1]);
            obj.browseLocationButton = uicontrol( ...
                'Parent', l, ...
                'Style', 'pushbutton', ...
                'String', 'Browse...', ...
                'Callback', @(h,d)notify(obj, 'BrowseLocation'));
            set(l, 'Sizes', [labelSize -1 75]);
            
            animalPanel = uix.Panel( ...
                'Parent', parametersLayout, ...
                'Title', 'Animal', ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            animalLayout = uiextras.VBox( ...
                'Parent', animalPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            obj.speciesDropDown = createLabeledDropDownMenu(animalLayout, 'Species:', [panelLabelSize -1]);
            obj.phenotypeDropDown = createLabeledDropDownMenu(animalLayout, 'Phenotype:', [panelLabelSize -1]);
            obj.genotypeDropDown = createLabeledDropDownMenu(animalLayout, 'Genotype:', [panelLabelSize -1]);
            set(animalLayout, 'Sizes', [25 25 25]);
            
            tissuePanel = uix.Panel( ...
                'Parent', parametersLayout, ...
                'Title', 'Tissue', ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            tissueLayout = uiextras.VBox( ...
                'Parent', tissuePanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            obj.preparationDropDown = createLabeledDropDownMenu(tissueLayout, 'Preparation:', [panelLabelSize -1]);
            set(tissueLayout, 'Sizes', [25]);
            
            set(parametersLayout, 'Sizes', [25 25 25 25 132 68]);
            
            % Open/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.openButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Open', ...
                'Callback', @(h,d)notify(obj, 'Open'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);
            
            set(mainLayout, 'Sizes', [-1 25]);       
            
            % Set open button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.openButton);
            end
        end
        
        function n = getName(obj)
            n = get(obj.nameField, 'String');
        end
        
        function setName(obj, n)
            set(obj.nameField, 'String', n);
        end
        
        function l = getLocation(obj)
            l = get(obj.locationField, 'String');
        end
        
        function setLocation(obj, l)
            set(obj.locationField, 'String', l);
        end
        
        function p = getPurpose(obj)
            p = get(obj.purposeField, 'String');
        end
        
        function setPurpose(obj, p)
            set(obj.purposeField, 'String', p);
        end
        
        function r = getRig(obj)
            r = SymphonyUI.Utilities.UI.getSelectedValue(obj.rigDropDown);
        end
        
        function s = getSpecies(obj)
            s = SymphonyUI.Utilities.UI.getSelectedValue(obj.speciesDropDown);
        end
        
        function setSpeciesList(obj, s)
            set(obj.speciesDropDown, 'String', s);
        end
        
    end
    
end

