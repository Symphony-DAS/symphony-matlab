classdef BeginEpochGroupView < symphonyui.ui.View

    events
        Begin
        Cancel
    end

    properties (Access = private)
        labelField
        sourcePopupMenu
        endCurrentEpochGroupCheckbox
        beginButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, ...
                'Name', 'Begin Epoch Group', ...
                'Position', screenCenter(250, 143));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            groupLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', groupLayout, ...
                'String', 'Label:');
            Label( ...
                'Parent', groupLayout, ...
                'String', 'Source:');
            uix.Empty('Parent', groupLayout);
            obj.labelField = uicontrol( ...
                'Parent', groupLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.sourcePopupMenu = MappedPopupMenu( ...
                'Parent', groupLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');            
            obj.endCurrentEpochGroupCheckbox = uicontrol( ...
                'Parent', groupLayout, ...
                'Style', 'checkbox', ...
                'String', 'End current epoch group', ...
                'HorizontalAlignment', 'left');
            set(groupLayout, ...
                'Widths', [40 -1], ...
                'Heights', [25 25 25]);

            % Begin/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.beginButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Begin', ...
                'Callback', @(h,d)notify(obj, 'Begin'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 25]);

            % Set begin button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.beginButton);
            end
        end

        function l = getLabel(obj)
            l = get(obj.labelField, 'String');
        end
        
        function requestLabelFocus(obj)
            obj.update();
            uicontrol(obj.labelField);
        end

        function s = getSelectedSource(obj)
            s = get(obj.sourcePopupMenu, 'Value');
        end

        function setSelectedSource(obj, s)
            set(obj.sourcePopupMenu, 'Value', s);
        end

        function setSourceList(obj, names, values)
            set(obj.sourcePopupMenu, 'String', names);
            set(obj.sourcePopupMenu, 'Values', values);
        end
        
        function enableShouldEndCurrentEpochGroup(obj, tf)
            set(obj.endCurrentEpochGroupCheckbox, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function setShouldEndCurrentEpochGroup(obj, tf)
            set(obj.endCurrentEpochGroupCheckbox, 'Value', tf);
        end
        
        function tf = getShouldEndCurrentEpochGroup(obj)
            tf = get(obj.endCurrentEpochGroupCheckbox, 'Value');
        end

    end

end
