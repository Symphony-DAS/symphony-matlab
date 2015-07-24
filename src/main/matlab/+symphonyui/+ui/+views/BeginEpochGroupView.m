classdef BeginEpochGroupView < symphonyui.ui.View

    events
        Begin
        Cancel
    end

    properties (Access = private)
        sourcePopupMenu
        descriptionPopupMenu
        beginButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, ...
                'Name', 'Begin Epoch Group', ...
                'Position', screenCenter(260, 111));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            groupLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', groupLayout, ...
                'String', 'Source:');
            Label( ...
                'Parent', groupLayout, ...
                'String', 'Description:');
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
                'Heights', [25 25]);

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
        
        function t = getSelectedDescription(obj)
            t = get(obj.descriptionPopupMenu, 'Value');
        end
        
        function setSelectedDescription(obj, t)
            set(obj.descriptionPopupMenu, 'Value', t);
        end
        
        function setDescriptionList(obj, names, values)
            set(obj.descriptionPopupMenu, 'String', names);
            set(obj.descriptionPopupMenu, 'Values', values);
        end
        
    end

end
