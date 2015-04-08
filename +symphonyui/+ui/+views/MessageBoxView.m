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
            
            set(obj.figureHandle, 'Position', screenCenter(270, 120));
            set(obj.figureHandle, 'WindowStyle', 'modal');
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            obj.messageText = uicontrol( ...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', '', ...
                'HorizontalAlignment', 'center');
            
            % Ok control.
            controlsLayout = uiextras.HBox('Parent', mainLayout);
            uiextras.Empty('Parent', controlsLayout');
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            uiextras.Empty('Parent', controlsLayout');
            set(controlsLayout, 'Sizes', [-1 75 -1]);
            
            set(mainLayout, 'Sizes', [-1 25]);
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
        end
        
        function setMessage(obj, m)
            set(obj.messageText, 'String', m);
        end
        
    end
    
end

