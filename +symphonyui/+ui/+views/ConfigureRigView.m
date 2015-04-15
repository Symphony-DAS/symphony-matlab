classdef ConfigureRigView < symphonyui.ui.View

    events
        AddDevice
        RemoveDevice
        Ok
        Cancel
    end

    properties (Access = private)
        daqDropDown
        deviceTable
        addButton
        removeButton
        okButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Configure Rig');
            set(obj.figureHandle, 'Position', screenCenter(400, 300));
            %set(obj.figureHandle, 'WindowStyle', 'modal');

            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            rigLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            rigLabelSize = 90;
            obj.daqDropDown = createLabeledDropDownMenu(rigLayout, 'DAQ Controller:', rigLabelSize);
            obj.deviceTable = createTable( ...
                'Parent', rigLayout, ...
                'Container', rigLayout, ...
                'Headers', {'Name', 'Input Stream', 'Output Stream'}, ...
                'Editable', false, ...
                'Buttons', 'off');
            obj.deviceTable.getTableScrollPane.getRowHeader.setVisible(0);
            set(rigLayout, 'Sizes', [25 -1]);
            
            % Ok/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Add...');
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Remove');
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
            set(controlsLayout, 'Sizes', [75 75 -1 75 75]);

            set(mainLayout, 'Sizes', [-1 25]);

            % Set ok button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end

        function d = getSelectedDaq(obj)
            d = symphonyui.ui.util.getSelectedValue(obj.daqDropDown);
        end
        
        function setSelectedDaq(obj, d)
            symphonyui.ui.util.setSelectedValue(obj.daqDropDown, d);
        end

        function setDaqList(obj, l)
            symphonyui.ui.util.setStringList(obj.setDaqList, l);
        end

    end

end
