classdef MessageBoxView < symphonyui.ui.View
    
    events
        Button1
        Button2
        Button3
    end
    
    properties (Access = private)
        text
        button1
        button2
        button3
    end
    
    methods
        
        function createUi(obj)
            import symphonyui.ui.util.*;
            
            set(obj.figureHandle, ...
                'Position', screenCenter(270, 120));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            obj.text = uicontrol( ...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'HorizontalAlignment', 'center');
            
            % Controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout');
            obj.button3 = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Button3', symphonyui.ui.UiEventData(get(obj.button3, 'String'))));
            obj.button2 = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Button2', symphonyui.ui.UiEventData(get(obj.button2, 'String'))));
            obj.button1 = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Button1', symphonyui.ui.UiEventData(get(obj.button1, 'String'))));
            set(controlsLayout, 'Widths', [-1 75 75 75]);
            
            set(mainLayout, 'Heights', [-1 25]);
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
        end
        
        function setText(obj, t)
            set(obj.text, 'String', t);
        end
        
        function setButton1(obj, s)
            set(obj.button1, 'String', s);
        end
        
        function setButton1Visible(obj, tf)
            set(obj.button1, 'Visible', symphonyui.ui.util.onOff(tf));
        end
        
        function setButton1Default(obj)
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.button1);
            end
        end
        
        function setButton2(obj, s)
            set(obj.button2, 'String', s);
        end
        
        function setButton2Visible(obj, tf)
            set(obj.button2, 'Visible', symphonyui.ui.util.onOff(tf));
        end
        
        function setButton2Default(obj)
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.button2);
            end
        end
        
        function setButton3(obj, s)
            set(obj.button3, 'String', s);
        end
        
        function setButton3Visible(obj, tf)
            set(obj.button3, 'Visible', symphonyui.ui.util.onOff(tf));
        end
        
        function setButton3Default(obj)
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.button3);
            end
        end
        
    end
    
end

