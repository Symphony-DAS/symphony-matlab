classdef AddKeywordView < appbox.View

    events
        Add
        Cancel
    end

    properties (Access = private)
        textField
        addButton
        cancelButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'Add Keyword', ...
                'Position', screenCenter(250, 79), ...
                'Resize', 'off');

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            keywordLayout = uix.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            obj.textField = IntelliHintsTextField( ...
                'Parent', keywordLayout, ...
                'HorizontalAlignment', 'left');
            set(keywordLayout, 'Heights', 23);

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

        function t = getText(obj)
            t = get(obj.textField, 'String');
        end

        function setTextCompletionList(obj, list)
            set(obj.textField, 'CompletionList', list);
        end

        function requestTextFocus(obj)
            obj.update();
            uicontrol(obj.textField);
        end

    end

end
