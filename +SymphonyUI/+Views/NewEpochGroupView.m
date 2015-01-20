classdef NewEpochGroupView < SymphonyUI.View
    
    events
        AddExternalSolution
        RemoveExternalSolution
        AddInternalSolution
        RemoveInternalSolution
        AddOther
        RemoveOther
        Begin
        Cancel
    end
    
    properties (Access = private)
        labelDropDown
        recordingDropDown
        keywordsField
        externalSolutionTab
        internalSolutionTab
        otherTab
        beginButton
        cancelButton
    end
    
    methods
        
        function obj = NewEpochGroupView(parent)
            obj = obj@SymphonyUI.View(parent);
        end
        
        function createUI(obj)
            import SymphonyUI.Utilities.*;
            import SymphonyUI.Utilities.UI.*;
            
            set(obj.figureHandle, 'Name', 'Begin Epoch Group');
            set(obj.figureHandle, 'Position', screenCenter(420, 320));
            
            labelSize = 60;
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            parametersLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.labelDropDown = createLabeledDropDownMenu(parametersLayout, 'Label:', [labelSize -1]);
            obj.recordingDropDown = createLabeledDropDownMenu(parametersLayout, 'Recording:', [labelSize -1]);
            obj.keywordsField = createLabeledTextField(parametersLayout, 'Keywords:', [labelSize -1]);
            
            panel = uix.Panel( ...
                'Parent', parametersLayout, ...
                'Padding', 1);
            propertiesPanel = uix.TabPanel( ...
                'Parent', panel, ...
                'TabWidth', 100, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            
            obj.externalSolutionTab = createTabUI(obj, propertiesPanel, 'AddExternalSolution', 'RemoveExternalSolution');
            obj.internalSolutionTab = createTabUI(obj, propertiesPanel, 'AddInternalSolution', 'RemoveInternalSolution');
            obj.otherTab = createTabUI(obj, propertiesPanel, 'AddOther', 'RemoveOther');
            set(propertiesPanel, 'TabTitles', {'External Solution', 'Internal Solution', 'Other'});
            
            set(parametersLayout, 'Sizes', [25 25 25 -1]);
            
            % Begin/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty(...
                'Parent', controlsLayout);
            obj.beginButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Begin', ...
                'Callback', @(h,d)notify(obj, 'Begin'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);
            
            set(mainLayout, 'Sizes', [-1 25]);
            
            % Set begin button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.beginButton);
            end
        end
        
        function setLabelList(obj, l)
            SymphonyUI.Utilities.UI.setStringList(obj.labelDropDown, l);
        end
        
        function l = getLabel(obj)
            l = SymphonyUI.Utilities.UI.getSelectedValue(obj.labelDropDown);
        end
        
        function setRecordingList(obj, r)
            SymphonyUI.Utilities.UI.setStringList(obj.recordingDropDown, r);
        end
        
        function r = getRecording(obj)
            r = SymphonyUI.Utilities.UI.getSelectedValue(obj.recordingDropDown);
        end
        
        function w = getKeywords(obj)
            w = get(obj.keywordsField, 'String');
        end
        
        function setAvailableExternalSolutionList(obj, s)
            SymphonyUI.Utilities.UI.setStringList(obj.externalSolutionTab.availableList, s);
        end
        
        function s = getAvailableExternalSolution(obj)
            s = SymphonyUI.Utilities.UI.getSelectedValue(obj.externalSolutionTab.availableList);
        end
        
        function s = getAddedExternalSolutionList(obj)
            s = get(obj.externalSolutionTab.addedList, 'String');
        end
        
        function setAddedExternalSolutionList(obj, s)
            SymphonyUI.Utilities.UI.setStringList(obj.externalSolutionTab.addedList, s);
        end
        
        function s = getAddedExternalSolution(obj)
            s = SymphonyUI.Utilities.UI.getSelectedValue(obj.externalSolutionTab.addedList);
        end
        
        function setAvailableInternalSolutionList(obj, s)
            SymphonyUI.Utilities.UI.setStringList(obj.internalSolutionTab.availableList, s);
        end
        
        function s = getAvailableInternalSolution(obj)
            s = SymphonyUI.Utilities.UI.getSelectedValue(obj.internalSolutionTab.availableList);
        end
        
        function s = getAddedInternalSolutionList(obj)
            s = get(obj.internalSolutionTab.addedList, 'String');
        end
        
        function setAddedInternalSolutionList(obj, s)
            SymphonyUI.Utilities.UI.setStringList(obj.internalSolutionTab.addedList, s);
        end
        
        function s = getAddedInternalSolution(obj)
            s = SymphonyUI.Utilities.UI.getSelectedValue(obj.internalSolutionTab.addedList);
        end
        
        function setAvailableOtherList(obj, s)
            SymphonyUI.Utilities.UI.setStringList(obj.otherTab.availableList, s);
        end
        
        function s = getAvailableOther(obj)
            s = SymphonyUI.Utilities.UI.getSelectedValue(obj.otherTab.availableList);
        end
        
        function s = getAddedOtherList(obj)
            s = get(obj.otherTab.addedList, 'String');
        end
        
        function setAddedOtherList(obj, s)
            SymphonyUI.Utilities.UI.setStringList(obj.otherTab.addedList, s);
        end
        
        function s = getAddedOther(obj)
            s = SymphonyUI.Utilities.UI.getSelectedValue(obj.otherTab.addedList);
        end
        
    end
    
end

function tab = createTabUI(obj, parent, addEvent, removeEvent)
    layout = uiextras.HBox( ...
        'Parent', parent, ...
        'Padding', 11, ...
        'Spacing', 7);

    vbox = uiextras.VBox( ...
        'Parent', layout, ...
        'Spacing', 3);
    uicontrol( ...
        'Parent', vbox, ...
        'Style', 'text', ...
        'String', 'Available:', ...
        'HorizontalAlignment', 'left');
    tab.availableList = uicontrol( ...
        'Parent', vbox, ...
        'Style', 'listbox', ...
        'String', {''});
    set(vbox, 'Sizes', [15 -1]);

    vbox = uiextras.VBox( ...
        'Parent', layout);
    uiextras.Empty('Parent', vbox);
    tab.addButton = uicontrol( ...
        'Parent', vbox, ...
        'Style', 'pushbutton', ...
        'String', 'Add->', ...
        'Callback', @(h,d)notify(obj, addEvent));
    obj.externalSolutionTab.removeButton = uicontrol( ...
        'Parent', vbox, ...
        'Style', 'pushbutton', ...
        'String', '<-Remove', ...
        'Callback', @(h,d)notify(obj, removeEvent));
    uiextras.Empty('Parent', vbox);
    set(vbox, 'Sizes', [-1 25 25 -1]);

    vbox = uiextras.VBox( ...
        'Parent', layout, ...
        'Spacing', 3);
    uicontrol( ...
        'Parent', vbox, ...
        'Style', 'text', ...
        'String', 'Added:', ...
        'HorizontalAlignment', 'left');
    tab.addedList = uicontrol( ...
        'Parent', vbox, ...
        'Style', 'listbox');
    set(vbox, 'Sizes', [15 -1]);

    set(layout, 'Sizes', [-1 80 -1]);
end
