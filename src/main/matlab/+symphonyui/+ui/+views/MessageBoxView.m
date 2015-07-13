classdef MessageBoxView < symphonyui.ui.View
    
    events
        Ok
    end
    
    properties (Access = private)
        messageText
        okButton
    end
    
    methods
        
        function createUi(obj)
            import symphonyui.ui.util.*;
            
            set(obj.figureHandle, ...
                'Position', screenCenter(270, 120), ...
                'WindowStyle', 'modal');
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            obj.messageText = uicontrol( ...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'HorizontalAlignment', 'center');
            
            % Ok control.
            controlsLayout = uix.HBox('Parent', mainLayout);
            uix.Empty('Parent', controlsLayout');
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            uix.Empty('Parent', controlsLayout');
            set(controlsLayout, 'Widths', [-1 75 -1]);
            
            set(mainLayout, 'Heights', [-1 25]);
            
            % Set Ok button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
        end
        
        function setMessage(obj, m)
            set(obj.messageText, 'String', m);
        end
        
    end
    
end

