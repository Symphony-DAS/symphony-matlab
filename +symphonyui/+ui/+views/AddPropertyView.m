classdef AddPropertyView < symphonyui.ui.View
    
    events
        Add
        Cancel
    end
    
    properties (Access = private)
        keyField
        valueField
        addButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import symphonyui.ui.util.*;
            
            set(obj.figureHandle, 'Name', 'Add Property');
            set(obj.figureHandle, 'Position', screenCenter(300, 111));
            set(obj.figureHandle, 'WindowStyle', 'modal');
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            propertyLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            propertyLabelSize = 50;
            obj.keyField = createLabeledTextField(propertyLayout, 'Key:', propertyLabelSize);
            obj.valueField = createLabeledTextField(propertyLayout, 'Value:', propertyLabelSize);
            set(propertyLayout, 'Sizes', [25 25]);
            
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
            
            set(mainLayout, 'Sizes', [57 25]);
            
            % Set add button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.addButton);
            end
        end
        
        function k = getKey(obj)
            k = get(obj.keyField, 'String');
        end
        
        function requestKeyFocus(obj)
            obj.requestFocus(obj.keyField);
        end
        
        function v = getValue(obj)
            v = get(obj.valueField, 'String');
        end
        
    end
    
end

