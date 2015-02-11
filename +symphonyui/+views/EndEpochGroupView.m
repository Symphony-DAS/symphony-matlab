classdef EndEpochGroupView < symphonyui.View
    
    events
        End
        Cancel
    end
    
    properties (Access = private)
        endButton
        cancelButton
    end
    
    methods
        
        function obj = EndEpochGroupView(parent)
            obj = obj@symphonyui.View(parent);
        end
        
        function createUI(obj)
            import symphonyui.util.*;
            import symphonyui.util.ui.*;
            
            set(obj.figureHandle, 'Name', 'End Epoch Group');
            set(obj.figureHandle, 'Position', screenCenter(420, 320));
            
            labelSize = 60;
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            parametersLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            % End/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty(...
                'Parent', controlsLayout);
            obj.endButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'End', ...
                'Callback', @(h,d)notify(obj, 'End'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);
            
            set(mainLayout, 'Sizes', [-1 25]);
            
            % Set end button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.endButton);
            end
        end
        
    end
    
end
