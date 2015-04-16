classdef LoadRigView < symphonyui.ui.View

    events
        BrowseLocation
        Load
        Cancel
    end
    
    properties (Access = private)
        locationField
        loadButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Load Rig');
            set(obj.figureHandle, 'Position', screenCenter(500, 79));
            set(obj.figureHandle, 'WindowStyle', 'modal');

            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            rigLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            rigLabelSize = 58;
            
            obj.locationField = createLabeledTextFieldWithButton(rigLayout, 'Location:', rigLabelSize, @(h,d)notify(obj, 'BrowseLocation'));

            % Ok/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.loadButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Load', ...
                'Callback', @(h,d)notify(obj, 'Load'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);

            set(mainLayout, 'Sizes', [-1 25]);

            % Set load button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.loadButton);
            end
        end

        function l = getLocation(obj)
            l = get(obj.locationField, 'String');
        end

        function setLocation(obj, l)
            set(obj.locationField, 'String', l);
        end

    end

end
