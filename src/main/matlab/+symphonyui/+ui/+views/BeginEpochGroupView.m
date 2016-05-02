classdef BeginEpochGroupView < appbox.View

    events
        SelectedParent
        Begin
        Cancel
    end

    properties (Access = private)
        parentPopupMenu
        sourcePopupMenu
        descriptionPopupMenu
        carryForwardPropertiesCheckBox
        beginButton
        cancelButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'Begin Epoch Group', ...
                'Position', screenCenter(300, 169));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            groupLayout = uix.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);

            groupGrid = uix.Grid( ...
                'Parent', groupLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', groupGrid, ...
                'String', 'Parent:');
            Label( ...
                'Parent', groupGrid, ...
                'String', 'Source:');
            Label( ...
                'Parent', groupGrid, ...
                'String', 'Description:');
            obj.parentPopupMenu = MappedPopupMenu( ...
                'Parent', groupGrid, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SelectedParent'));
            obj.sourcePopupMenu = MappedPopupMenu( ...
                'Parent', groupGrid, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            obj.descriptionPopupMenu = MappedPopupMenu( ...
                'Parent', groupGrid, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(groupGrid, ...
                'Widths', [65 -1], ...
                'Heights', [23 23 23]);

            obj.carryForwardPropertiesCheckBox = uicontrol( ...
                'Parent', groupLayout, ...
                'Style', 'checkbox', ...
                'String', 'Carry forward properties from last epoch group');

            set(groupLayout, 'Heights', [layoutHeight(groupGrid) 23]);

            % Begin/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.beginButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Begin', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Begin'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 23]);

            % Set begin button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.beginButton);
            end
        end

        function enableBegin(obj, tf)
            set(obj.beginButton, 'Enable', appbox.onOff(tf));
        end

        function tf = getEnableBegin(obj)
            tf = appbox.onOff(get(obj.beginButton, 'Enable'));
        end

        function enableSelectParent(obj, tf)
            set(obj.parentPopupMenu, 'Enable', appbox.onOff(tf));
        end

        function p = getSelectedParent(obj)
            p = get(obj.parentPopupMenu, 'Value');
        end

        function setSelectedParent(obj, p)
            set(obj.parentPopupMenu, 'Value', p);
        end

        function l = getParentList(obj)
            l = get(obj.parentPopupMenu, 'Values');
        end

        function setParentList(obj, names, values)
            set(obj.parentPopupMenu, 'String', names);
            set(obj.parentPopupMenu, 'Values', values);
        end

        function enableSelectSource(obj, tf)
            set(obj.sourcePopupMenu, 'Enable', appbox.onOff(tf));
        end

        function s = getSelectedSource(obj)
            s = get(obj.sourcePopupMenu, 'Value');
        end

        function setSelectedSource(obj, s)
            set(obj.sourcePopupMenu, 'Value', s);
        end

        function l = getSourceList(obj)
            l = get(obj.sourcePopupMenu, 'Values');
        end

        function setSourceList(obj, names, values)
            set(obj.sourcePopupMenu, 'String', names);
            set(obj.sourcePopupMenu, 'Values', values);
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

        function enableCarryForwardProperties(obj, tf)
            set(obj.carryForwardPropertiesCheckBox, 'Enable', appbox.onOff(tf));
        end

        function tf = getCarryForwardProperties(obj)
            tf = get(obj.carryForwardPropertiesCheckBox, 'Value');
        end

        function setCarryForwardProperties(obj, tf)
            set(obj.carryForwardPropertiesCheckBox, 'Value', tf);
        end

    end

end
