classdef HoldingLevelsView < symphonyui.ui.View

    events
        Apply
        Cancel
    end
    
    properties (Access = private)
        levelsPropertyGrid
        applyButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;
            
            set(obj.figureHandle, ...
                'Name', 'Holding Levels', ...
                'Position', screenCenter(240, 150));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            levelsLayout = uix.VBox( ...
                'Parent', mainLayout);
            
            obj.levelsPropertyGrid = uiextras.jide.PropertyGrid(levelsLayout, ...
                'ShowDescription', false);

            % Apply/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.applyButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Apply', ...
                'Callback', @(h,d)notify(obj, 'Apply'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 25]);

            % Set apply button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.applyButton);
            end
        end
        
        function f = getHoldingLevels(obj)
            f = get(obj.levelsPropertyGrid, 'Properties');
        end
        
        function setHoldingLevels(obj, fields)
            set(obj.levelsPropertyGrid, 'Properties', fields);
        end

    end

end
