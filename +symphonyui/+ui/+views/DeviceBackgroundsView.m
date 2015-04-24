classdef DeviceBackgroundsView < symphonyui.ui.View

    events
        Apply
        Cancel
    end

    properties (Access = private)
        backgroundsLayout
        textFields
        applyButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Device Backgrounds');
            set(obj.figureHandle, 'Position', screenCenter(260, 200));
            set(obj.figureHandle, 'WindowStyle', 'modal');

            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            obj.backgroundsLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.textFields = struct();

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

            % Set OK button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.applyButton);
            end
        end
        
        function pack(obj)
            sizes = get(obj.backgroundsLayout, 'Sizes');
            sizes(:) = 25;
            set(obj.backgroundsLayout, 'Sizes', sizes);
            
            height = (25 + 7) * numel(fieldnames(obj.textFields)) + 11 * 2 + 25 + 7;
            position = get(obj.figureHandle, 'Position');
            position(4) = height;
            set(obj.figureHandle, 'Position', position);
        end
        
        function addBackground(obj, name, quantity, units)
            layout = uiextras.HBox( ...
                'Parent', obj.backgroundsLayout, ...
                'Spacing', 7);
            label = symphonyui.ui.util.createLabel(layout, [name ' (' units '):']);
            set(label, 'HorizontalAlignment', 'right');
            obj.textFields.(name) = uicontrol( ...
                'Parent', layout, ...
                'Style', 'edit', ...
                'String', quantity, ...
                'HorizontalAlignment', 'left');
        end
        
        function q = getBackground(obj, name)
            q = get(obj.textFields.(name), 'String');
        end

    end

end
