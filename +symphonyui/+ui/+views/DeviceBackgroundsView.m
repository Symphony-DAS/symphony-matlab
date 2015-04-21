classdef DeviceBackgroundsView < symphonyui.ui.View
    
    events
        Apply
        Cancel
    end
    
    properties (Access = private)
        deviceGrid
        applyButton
        cancelButton
    end
    
    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Device Backgrounds');
            set(obj.figureHandle, 'Position', screenCenter(300, 200));
            set(obj.figureHandle, 'WindowStyle', 'modal');

            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            backgroundLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            obj.deviceGrid = uiextras.jide.PropertyGrid(backgroundLayout);
            
            % Apply/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.applyButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Apply', ...
                'Callback', @(h,d)notify(obj, 'Apply'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);

            set(mainLayout, 'Sizes', [-1 25]);
        end

    end

end
