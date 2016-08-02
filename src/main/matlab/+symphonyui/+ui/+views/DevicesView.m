classdef DevicesView < appbox.View

    events
        SelectedDevices
        SetBackground
        SetConfigurationSetting
        AddConfigurationSetting
        RemoveConfigurationSetting
        Ok
    end

    properties (Access = private)
        deviceListBox
        nameField
        manufacturerField
        inputStreamsField
        outputStreamsField
        backgroundField
        backgroundUnitsField
        configurationPropertyGrid
        addConfigurationSettingButton
        removeConfigurationSettingButton
        okButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'Devices', ...
                'Position', screenCenter(500, 300));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            devicesLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);

            masterLayout = uix.VBox( ...
                'Parent', devicesLayout);

            obj.deviceListBox = MappedListBox( ...
                'Parent', masterLayout, ...
                'Max', 10, ...
                'Min', 1, ...
                'Enable', 'off', ...
                'Callback', @(h,d)notify(obj, 'SelectedDevices'));

            detailLayout = uix.VBox( ...
                'Parent', devicesLayout);

            deviceLayout = uix.VBox( ...
                'Parent', detailLayout, ...
                'Spacing', 7);
            deviceGrid = uix.Grid( ...
                'Parent', deviceLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', deviceGrid, ...
                'String', 'Name:');
            Label( ...
                'Parent', deviceGrid, ...
                'String', 'Manufacturer:');
            Label( ...
                'Parent', deviceGrid, ...
                'String', 'Input streams:');
            Label( ...
                'Parent', deviceGrid, ...
                'String', 'Output streams:');
            Label( ...
                'Parent', deviceGrid, ...
                'String', 'Background:');
            configurationLabelLayout = uix.VBox( ...
                'Parent', deviceGrid);
            Label( ...
                'Parent', configurationLabelLayout, ...
                'String', 'Configuration:');
            uix.Empty('Parent', configurationLabelLayout);
            set(configurationLabelLayout, 'Heights', [23 -1]);
            obj.nameField = uicontrol( ...
                'Parent', deviceGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.manufacturerField = uicontrol( ...
                'Parent', deviceGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.inputStreamsField = uicontrol( ...
                'Parent', deviceGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.outputStreamsField = uicontrol( ...
                'Parent', deviceGrid, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            backgroundLayout = uix.HBox( ...
                'Parent', deviceGrid, ...
                'Spacing', 5);
            obj.backgroundField = uicontrol( ...
                'Parent', backgroundLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SetBackground'));
            obj.backgroundUnitsField = uicontrol( ...
                'Parent', backgroundLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            configurationLayout = uix.VBox( ...
                'Parent', deviceGrid, ...
                'Spacing', 1);
            obj.configurationPropertyGrid = uiextras.jide.PropertyGrid(configurationLayout, ...
                'Callback', @(h,d)notify(obj, 'SetConfigurationSetting', symphonyui.ui.UiEventData(d)));
            configurationToolbarLayout = uix.HBox( ...
                'Parent', configurationLayout);
            uix.Empty('Parent', configurationToolbarLayout);
            obj.addConfigurationSettingButton = Button( ...
                'Parent', configurationToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'add.png'), ...
                'TooltipString', 'Add Configuration Setting...', ...
                'Callback', @(h,d)notify(obj, 'AddConfigurationSetting'));
            obj.removeConfigurationSettingButton = Button( ...
                'Parent', configurationToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'remove.png'), ...
                'TooltipString', 'Remove Configuration Setting', ...
                'Callback', @(h,d)notify(obj, 'RemoveConfigurationSetting'));
            set(configurationToolbarLayout, 'Widths', [-1 22 22]);

            set(configurationLayout, 'Heights', [-1 22]);

            set(deviceGrid, ...
                'Widths', [90 -1], ...
                'Heights', [23 23 23 23 23 -1]);

            javacomponent('javax.swing.JSeparator', [], detailLayout);

            set(detailLayout, 'Heights', [-1 1]);

            set(devicesLayout, 'Widths', [-1 -2]);

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

        function close(obj)
            close@appbox.View(obj);
            obj.configurationPropertyGrid.Close();
        end

        function d = getSelectedDevices(obj)
            d = get(obj.deviceListBox, 'Value');
        end

        function enableDeviceList(obj, tf)
            set(obj.deviceListBox, 'Enable', appbox.onOff(tf));
        end

        function setDeviceList(obj, names, values)
            set(obj.deviceListBox, 'String', names);
            set(obj.deviceListBox, 'Values', values);
        end

        function setName(obj, n)
            set(obj.nameField, 'String', n);
        end

        function setManufacturer(obj, m)
            set(obj.manufacturerField, 'String', m);
        end

        function setInputStreams(obj, s)
            set(obj.inputStreamsField, 'String', s);
        end

        function setOutputStreams(obj, s)
            set(obj.outputStreamsField, 'String', s);
        end

        function enableBackground(obj, tf)
            set(obj.backgroundField, 'Enable', appbox.onOff(tf));
        end

        function setBackground(obj, b)
            set(obj.backgroundField, 'String', b);
        end

        function b = getBackground(obj)
            b = get(obj.backgroundField, 'String');
        end

        function setBackgroundUnits(obj, u)
            set(obj.backgroundUnitsField, 'String', u);
        end

        function u = getBackgroundUnits(obj)
            u = get(obj.backgroundUnitsField, 'String');
        end

        function p = getSelectedConfigurationSetting(obj)
            p = obj.configurationPropertyGrid.GetSelectedProperty();
        end

        function setConfiguration(obj, fields)
            set(obj.configurationPropertyGrid, 'Properties', fields);
        end

        function updateConfiguration(obj, fields)
            obj.configurationPropertyGrid.UpdateProperties(fields);
        end

        function stopEditingConfiguration(obj)
            obj.configurationPropertyGrid.StopEditing();
        end

        function enableAddConfigurationSetting(obj, tf)
            set(obj.addConfigurationSettingButton, 'Enable', appbox.onOff(tf));
        end

        function enableRemoveConfigurationSetting(obj, tf)
            set(obj.removeConfigurationSettingButton, 'Enable', appbox.onOff(tf));
        end

        function requestFigureFocus(obj)
            obj.update();
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            jframe = get(handle(obj.figureHandle), 'JavaFrame');
            warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            jframe.getAxisComponent().requestFocus();
        end

    end

end
