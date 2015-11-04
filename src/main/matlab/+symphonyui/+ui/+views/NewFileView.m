classdef NewFileView < appbox.View

    events
        BrowseLocation
        Ok
        Cancel
    end

    properties (Access = private)
        nameField
        locationField
        browseLocationButton
        descriptionPopupMenu
        okButton
        cancelButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'New File', ...
            	'Position', screenCenter(500, 143));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            fileLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', fileLayout, ...
                'String', 'Name:');
            Label( ...
                'Parent', fileLayout, ...
                'String', 'Location:');
            Label( ...
                'Parent', fileLayout, ...
                'String', 'Description:');
            obj.nameField = uicontrol( ...
                'Parent', fileLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.locationField = uicontrol( ...
                'Parent', fileLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.descriptionPopupMenu = MappedPopupMenu( ...
                'Parent', fileLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            uix.Empty('Parent', fileLayout);
            obj.browseLocationButton = uicontrol( ...
                'Parent', fileLayout, ...
                'Style', 'pushbutton', ...
                'String', '...', ...
                'Callback', @(h,d)notify(obj, 'BrowseLocation'));
            uix.Empty('Parent', fileLayout);
            set(fileLayout, ...
                'Widths', [65 -1 25], ...
                'Heights', [25 25 25]);

            % OK/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 25]);

            % Set OK button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end
        
        function enableOk(obj, tf)
            set(obj.okButton, 'Enable', appbox.onOff(tf));
        end

        function n = getName(obj)
            n = get(obj.nameField, 'String');
        end

        function setName(obj, n)
            set(obj.nameField, 'String', n);
        end
        
        function requestNameFocus(obj)
            obj.update();
            uicontrol(obj.nameField);
        end

        function l = getLocation(obj)
            l = get(obj.locationField, 'String');
        end

        function setLocation(obj, l)
            set(obj.locationField, 'String', l);
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
