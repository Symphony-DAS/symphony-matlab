classdef InitializeRigView < symphonyui.ui.View

    events
        Initialize
        Cancel
    end
    
    properties (Access = private)
        descriptionPopupMenu
        initializeButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;
            
            set(obj.figureHandle, ...
                'Name', 'Initialize Rig', ...
                'Position', screenCenter(260, 79));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            rigLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', rigLayout, ...
                'String', 'Description:');
            obj.descriptionPopupMenu = MappedPopupMenu( ...
                'Parent', rigLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(rigLayout, ...
                'Widths', [65 -1], ...
                'Heights', [25]);

            % Intialize/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.initializeButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Initialize', ...
                'Callback', @(h,d)notify(obj, 'Initialize'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 25]);

            % Set initialize button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.initializeButton);
            end
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
