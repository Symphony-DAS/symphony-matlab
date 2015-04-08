classdef SelectRigView < symphonyui.ui.View

    events
        Ok
        Cancel
    end

    properties (Access = private)
        rigDropDown
        okButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Select Rig');
            set(obj.figureHandle, 'Position', screenCenter(250, 79));
            set(obj.figureHandle, 'WindowStyle', 'modal');

            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            rigLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);

            obj.rigDropDown = createLabeledDropDownMenu(rigLayout, 'Rig:', 25);

            % Ok/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);

            set(mainLayout, 'Sizes', [-1 25]);

            % Set ok button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end

        function r = getSelectedRig(obj)
            r = symphonyui.ui.util.getSelectedValue(obj.rigDropDown);
        end

        function setSelectedRig(obj, r)
            symphonyui.ui.util.setSelectedValue(obj.rigDropDown, r);
        end

        function setRigList(obj, l)
            symphonyui.ui.util.setStringList(obj.rigDropDown, l);
        end

        function enableOk(obj, tf)
            set(obj.okButton, 'Enable', onOff(tf));
        end

    end

end
