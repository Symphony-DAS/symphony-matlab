classdef AddNoteView < symphonyui.ui.View
    
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
            import symphonyui.ui.util.*;
            
            set(obj.figureHandle, ...
                'Name', 'Add Note', ...
                'Position', screenCenter(250, 79));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            noteLayout = uix.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            obj.textField = uicontrol( ...
                'Parent', noteLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            set(noteLayout, 'Heights', 25);
            
            % Add/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.addButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Add', ...
                'Callback', @(h,d)notify(obj, 'Add'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);
            
            set(mainLayout, 'Heights', [-1 25]);
            
            % Set add button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.addButton);
            end
        end
        
        function t = getText(obj)
            t = get(obj.textField, 'String');
        end
        
        function requestTextFocus(obj)
            obj.update();
            uicontrol(obj.textField);
        end
        
    end
    
end

