classdef NewExperimentView < symphonyui.ui.View

    events
        BrowseLocation
        Open
        Cancel
    end

    properties (Access = private)
        nameField
        locationField
        openButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'New Experiment');
            set(obj.figureHandle, 'Position', screenCenter(500, 115));
            set(obj.figureHandle, 'WindowStyle', 'modal');

            labelSize = 58;
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            parametersLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);

            obj.nameField = createLabeledTextField(parametersLayout, 'Name:', labelSize);
            obj.locationField = createLabeledTextFieldWithButton(parametersLayout, 'Location:', labelSize, @(h,d)notify(obj, 'BrowseLocation'));

            set(parametersLayout, 'Sizes', [25 25]);

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

    end

end
