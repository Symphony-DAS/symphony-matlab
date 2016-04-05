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
        beginButton
        cancelButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'Begin Epoch Group', ...
                'Position', screenCenter(260, 139));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            groupLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', groupLayout, ...
                'String', 'Parent:');
            Label( ...
                'Parent', groupLayout, ...
                'String', 'Source:');
            Label( ...
                'Parent', groupLayout, ...
                'String', 'Description:');
            obj.parentPopupMenu = MappedPopupMenu( ...
                'Parent', groupLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SelectedParent'));
            obj.sourcePopupMenu = MappedPopupMenu( ...
                'Parent', groupLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            obj.descriptionPopupMenu = MappedPopupMenu( ...
                'Parent', groupLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(groupLayout, ...
                'Widths', [65 -1], ...
                'Heights', [23 23 23]);

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

    end

end
