classdef DeviceBackgroundsView < appbox.View

    events
        Apply
        Cancel
    end
    
    properties (Access = private)
        backgroundsPropertyGrid
        applyButton
        cancelButton
    end

    methods

        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Device Backgrounds', ...
                'Position', screenCenter(300, 160));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            backgroundsLayout = uix.VBox( ...
                'Parent', mainLayout);
            
            obj.backgroundsPropertyGrid = uiextras.jide.PropertyGrid(backgroundsLayout, ...
                'ShowDescription', false);

            % Apply/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.applyButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Apply', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Apply'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 25]);

            % Set apply button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.applyButton);
            end
        end
        
        function f = getDeviceBackgrounds(obj)
            f = get(obj.backgroundsPropertyGrid, 'Properties');
        end
        
        function setDeviceBackgrounds(obj, fields)
            set(obj.backgroundsPropertyGrid, 'Properties', fields);
        end
        
        function stopEditingDeviceBackgrounds(obj)
            obj.backgroundsPropertyGrid.StopEditing();
        end

    end

end
