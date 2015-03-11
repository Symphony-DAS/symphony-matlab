classdef BeginEpochGroupView < symphonyui.ui.View
    
    events
        Begin
        Cancel
    end
    
    properties (Access = private)
        parentField
        labelDropDown
        beginButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import symphonyui.util.*;
            import symphonyui.util.ui.*;
            
            set(obj.figureHandle, 'Name', 'Begin Epoch Group');
            set(obj.figureHandle, 'Position', screenCenter(300, 111));
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            groupLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            groupLabelSize = 40;
            obj.parentField = createLabeledTextField(groupLayout, 'Parent:', [groupLabelSize -1]);
            set(obj.parentField, 'Enable', 'off');
            obj.labelDropDown = createLabeledDropDownMenu(groupLayout, 'Label:', [groupLabelSize -1]);
            set(groupLayout, 'Sizes', [25 25]);
            
            % Begin/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
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
        
        function setParent(obj, p)
            set(obj.parentField, 'String', p);
        end
        
        function l = getSelectedLabel(obj)
            l = symphonyui.util.ui.getSelectedValue(obj.labelDropDown);
        end
        
        function setLabelList(obj, l)
            symphonyui.util.ui.setStringList(obj.labelDropDown, l);
        end
        
    end
    
end

