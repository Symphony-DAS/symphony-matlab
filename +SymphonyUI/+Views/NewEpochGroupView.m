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
        labelPopup
        recordingPopup
        keywordsEdit
        propertiesPanel
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
            
            set(obj.figureHandle, 'Name', 'Begin Epoch Group');
            set(obj.figureHandle, 'Position', screenCenter(420, 320));
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            parametersLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            % Label input.
            layout = uiextras.HBox( ...
                'Parent', parametersLayout, ...
                'Spacing', 7);
            uiLabel(layout, 'Label:');
            obj.labelPopup = uicontrol( ...
                'Parent', layout, ...
                'Style', 'popupmenu', ...
                'String', {'Control', 'Drug', 'Wash'}, ...
                'HorizontalAlignment', 'left');
            set(layout, 'Sizes', [60 -1]);
            
            % Recording input.
            layout = uiextras.HBox( ...
                'Parent', parametersLayout, ...
                'Spacing', 7);
            uiLabel(layout, 'Recording:');
            obj.recordingPopup = uicontrol( ...
                'Parent', layout, ...
                'Style', 'popupmenu', ...
                'String', {'Extracellular', 'Whole-cell', 'Suction'}, ...
                'HorizontalAlignment', 'left');
            set(layout, 'Sizes', [60 -1]);
            
            % Keywords input.
            layout = uiextras.HBox( ...
                'Parent', parametersLayout, ...
                'Spacing', 7);
            uiLabel(layout, 'Keywords:');
            obj.keywordsEdit = uicontrol( ...
                'Parent', layout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            set(layout, 'Sizes', [60 -1]);
            
            % Properties panel.
            panel = uix.Panel( ...
                'Parent', parametersLayout, ...
                'Padding', 1);
            obj.propertiesPanel = uix.TabPanel( ...
                'Parent', panel, ...
                'TabWidth', 100, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            
            % External solution tab.
            obj.externalSolutionTab = createTabUI(obj, obj.propertiesPanel, 'AddExternalSolution', 'RemoveExternalSolution');
            
            % Internal solution tab.
            obj.internalSolutionTab = createTabUI(obj, obj.propertiesPanel, 'AddInternalSolution', 'RemoveInternalSolution');
            
            % Other tab.
            obj.otherTab = createTabUI(obj, obj.propertiesPanel, 'AddOther', 'RemoveOther');
            
            set(obj.propertiesPanel, 'TabTitles', {'External Solution', 'Internal Solution', 'Other'});
            
            set(parametersLayout, 'Sizes', [25 25 25 -1]);
            
            % Begin/Cancel controls.
            controlLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty(...
                'Parent', controlLayout);
            obj.beginButton = uicontrol( ...
                'Parent', controlLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Begin', ...
                'Callback', @(h,d)notify(obj, 'Begin'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlLayout, 'Sizes', [-1 75 75]);
            
            set(mainLayout, 'Sizes', [-1 25]);
            
            % Set begin button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.beginButton);
            end
        end
        
        function setLabels(obj, l)
            SymphonyUI.Utilities.setUIList(obj.labelPopup, l);
        end
        
        function l = getLabel(obj)
            l = SymphonyUI.Utilities.getSelectedUIValue(obj.labelPopup);
        end
        
        function setRecordings(obj, r)
            SymphonyUI.Utilities.setUIList(obj.recordingPopup, r);
        end
        
        function r = getRecording(obj)
            r = SymphonyUI.Utilities.getSelectedUIValue(obj.recordingPopup);
        end
        
        function w = getKeywords(obj)
            w = get(obj.keywordsEdit, 'String');
        end
        
        function setAvailableExternalSolutions(obj, s)
            SymphonyUI.Utilities.setUIList(obj.externalSolutionTab.availableList, s);
        end
        
        function s = getAvailableExternalSolution(obj)
            s = SymphonyUI.Utilities.getSelectedUIValue(obj.externalSolutionTab.availableList);
        end
        
        function setAddedExternalSolutions(obj, s)
            SymphonyUI.Utilities.setUIList(obj.externalSolutionTab.addedList, s);
        end
        
        function s = getAddedExternalSolutions(obj)
            s = get(obj.externalSolutionTab.addedList, 'String');
        end
        
        function s = getAddedExternalSolution(obj)
            s = SymphonyUI.Utilities.getSelectedUIValue(obj.externalSolutionTab.addedList);
        end
        
        function setAvailableInternalSolutions(obj, s)
            SymphonyUI.Utilities.setUIList(obj.internalSolutionTab.availableList, s);
        end
        
        function s = getAvailableInternalSolution(obj)
            s = SymphonyUI.Utilities.getSelectedUIValue(obj.internalSolutionTab.availableList);
        end
        
        function setAddedInternalSolutions(obj, s)
            SymphonyUI.Utilities.setUIList(obj.internalSolutionTab.addedList, s);
        end
        
        function s = getAddedInternalSolutions(obj)
            s = get(obj.internalSolutionTab.addedList, 'String');
        end
        
        function s = getAddedInternalSolution(obj)
            s = SymphonyUI.Utilities.getSelectedUIValue(obj.internalSolutionTab.addedList);
        end
        
        function setAvailableOthers(obj, s)
            SymphonyUI.Utilities.setUIList(obj.otherTab.availableList, s);
        end
        
        function s = getAvailableOther(obj)
            s = SymphonyUI.Utilities.getSelectedUIValue(obj.otherTab.availableList);
        end
        
        function setAddedOthers(obj, s)
            SymphonyUI.Utilities.setUIList(obj.otherTab.addedList, s);
        end
        
        function s = getAddedOthers(obj)
            s = get(obj.otherTab.addedList, 'String');
        end
        
        function s = getAddedOther(obj)
            s = SymphonyUI.Utilities.getSelectedUIValue(obj.otherTab.addedList);
        end
        
        function s = getSource(obj)
            s = [];
        end
        
    end
    
end

function tab = createTabUI(obj, parent, addEvent, removeEvent)
    layout = uiextras.HBox( ...
        'Parent', parent, ...
        'Padding', 11, ...
        'Spacing', 7, ...
        'BackgroundColor', [238/255 238/255 238/255]);

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
        'String', '   Add->', ...
        'Callback', @(h,d)notify(obj, addEvent));
    obj.externalSolutionTab.removeButton = uicontrol( ...
        'Parent', vbox, ...
        'Style', 'pushbutton', ...
        'String', '<-Remove    ', ...
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
