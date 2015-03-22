classdef AddSourceView < symphonyui.ui.View
    
    events
        Add
        Cancel
    end
    
    properties (Access = private)
        parentField
        labelDropDown
        addButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import symphonyui.util.*;
            import symphonyui.util.ui.*;
            
            set(obj.figureHandle, 'Name', 'Add Source');
            set(obj.figureHandle, 'Position', screenCenter(300, 111));
            set(obj.figureHandle, 'WindowStyle', 'modal');
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            sourceLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            sourceLabelSize = 40;
            obj.parentField = createLabeledTextField(sourceLayout, 'Parent:', [sourceLabelSize -1]);
            set(obj.parentField, 'Enable', 'off');
            obj.labelDropDown = createLabeledDropDownMenu(sourceLayout, 'Label:', [sourceLabelSize -1]);
            set(sourceLayout, 'Sizes', [25 25]);
            
            % Add/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.addButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Add', ...
                'Callback', @(h,d)notify(obj, 'Add'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);
            
            set(mainLayout, 'Sizes', [-1 25]);
            
            % Set add button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.addButton);
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

