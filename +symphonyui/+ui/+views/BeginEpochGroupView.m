classdef BeginEpochGroupView < symphonyui.ui.View

    events
        Begin
        Cancel
    end

    properties (Access = private)
        parentField
        labelField
        sourceDropDown
        beginButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Begin Epoch Group');
            set(obj.figureHandle, 'Position', screenCenter(300, 143));
            set(obj.figureHandle, 'WindowStyle', 'modal');

            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            groupLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            groupLabelSize = 40;
            obj.parentField = createLabeledTextField(groupLayout, 'Parent:', groupLabelSize, 'Enable', 'off');
            obj.labelField = createLabeledTextField(groupLayout, 'Label:', groupLabelSize);
            obj.sourceDropDown = createLabeledDropDownMenu(groupLayout, 'Source:', groupLabelSize);
            set(groupLayout, 'Sizes', [25 25 25]);

            % Begin/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
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
            set(controlsLayout, 'Sizes', [-1 75 75]);

            set(mainLayout, 'Sizes', [-1 25]);

            % Set begin button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.beginButton);
            end
        end

        function setParent(obj, p)
            set(obj.parentField, 'String', p);
        end

        function l = getLabel(obj)
            l = get(obj.labelField, 'String');
        end
        
        function requestLabelFocus(obj)
            obj.requestFocus(obj.labelField);
        end

        function s = getSelectedSource(obj)
            s = symphonyui.ui.util.getSelectedValue(obj.sourceDropDown);
        end

        function setSelectedSource(obj, s)
            symphonyui.ui.util.setSelectedValue(obj.sourceDropDown, s);
        end

        function l = getSourceList(obj)
            l = get(obj.sourceDropDown, 'String');
        end

        function setSourceList(obj, l)
            symphonyui.ui.util.setStringList(obj.sourceDropDown, l);
        end

    end

end
