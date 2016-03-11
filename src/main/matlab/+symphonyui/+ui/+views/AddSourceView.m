classdef AddSourceView < appbox.View

    events
        SelectedParent
        Add
        Cancel
    end

    properties (Access = private)
        parentPopupMenu
        descriptionPopupMenu
        addButton
        cancelButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'Add Source', ...
                'Position', screenCenter(260, 109));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            sourceLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', sourceLayout, ...
                'String', 'Parent:');
            Label( ...
                'Parent', sourceLayout, ...
                'String', 'Description:');
            obj.parentPopupMenu = MappedPopupMenu( ...
                'Parent', sourceLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SelectedParent'));
            obj.descriptionPopupMenu = MappedPopupMenu( ...
                'Parent', sourceLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(sourceLayout, ...
                'Widths', [65 -1], ...
                'Heights', [23 23]);

            % Add/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.addButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Add', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Add'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 23]);

            % Set add button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.addButton);
            end
        end

        function enableAdd(obj, tf)
            set(obj.addButton, 'Enable', appbox.onOff(tf));
        end
        
        function tf = getEnableAdd(obj)
            tf = appbox.onOff(get(obj.addButton, 'Enable'));
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
