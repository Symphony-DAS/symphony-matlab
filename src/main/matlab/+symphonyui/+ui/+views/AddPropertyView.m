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
            
            set(obj.figureHandle, ...
                'Name', 'Add Property', ...
                'Position', screenCenter(300, 111));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            propertyLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', propertyLayout, ...
                'String', 'Key:');
            Label( ...
                'Parent', propertyLayout, ...
                'String', 'Value:');
            obj.keyField = uicontrol( ...
                'Parent', propertyLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.valueField = uicontrol( ...
                'Parent', propertyLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            set(propertyLayout, ...
                'Widths', [40 -1], ...
                'Heights', [25 25]);
            
            % Add/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
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
            set(controlsLayout, 'Widths', [-1 75 75]);
            
            set(mainLayout, 'Heights', [-1 25]);
            
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
            obj.update();
            uicontrol(obj.keyField);
        end
        
        function v = getValue(obj)
            v = get(obj.valueField, 'String');
        end
        
    end
    
end

