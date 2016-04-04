classdef EntityPresetsView < appbox.View

    events
        Ok
    end

    properties (Access = private)
        okButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'Entity Presets', ...
                'Position', screenCenter(300, 300));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            presetsLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            % OK control.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            set(controlsLayout, 'Sizes', [-1 75]);

            set(mainLayout, 'Heights', [-1 23]);

            % Set OK button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end

    end

end

