classdef InitializeRigView < appbox.View

    events
        Initialize
        Cancel
    end

    properties (Access = private)
        descriptionPopupMenu
        initializeButton
        cancelButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'Initialize Rig', ...
                'Position', screenCenter(230, 79));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            rigLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            obj.descriptionPopupMenu = MappedPopupMenu( ...
                'Parent', rigLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(rigLayout, ...
                'Widths', -1, ...
                'Heights', 23);

            % Intialize/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.initializeButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Initialize', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Initialize'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 23]);

            % Set initialize button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.initializeButton);
            end
        end

        function enableInitialize(obj, tf)
            set(obj.initializeButton, 'Enable', appbox.onOff(tf));
        end

        function enableSelectDescription(obj, tf)
            set(obj.descriptionPopupMenu, 'Enable', appbox.onOff(tf));
        end

        function t = getSelectedDescription(obj)
            t = get(obj.descriptionPopupMenu, 'Value');
        end

        function setSelectedDescription(obj, t)
            set(obj.descriptionPopupMenu, 'Value', t);
        end

        function l = getDescriptionList(obj)
            l = get(obj.descriptionPopupMenu, 'Values');
        end

        function setDescriptionList(obj, names, values)
            set(obj.descriptionPopupMenu, 'String', names);
            set(obj.descriptionPopupMenu, 'Values', values);
        end

    end

end
