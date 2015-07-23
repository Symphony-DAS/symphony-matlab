classdef AddSourceView < symphonyui.ui.View

    events
        Add
        Cancel
    end
    
    properties (Access = private)
        parentPopupMenu
        templatePopupMenu
        addButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, ...
                'Name', 'Add Source', ...
                'Position', screenCenter(250, 111));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            sourceLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', sourceLayout, ...
                'String', 'Parent:');
            Label( ...
                'Parent', sourceLayout, ...
                'String', 'Template:');
            obj.parentPopupMenu = MappedPopupMenu( ...
                'Parent', sourceLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            obj.templatePopupMenu = MappedPopupMenu( ...
                'Parent', sourceLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(sourceLayout, ...
                'Widths', [55 -1], ...
                'Heights', [25 25]);

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
        
        function enableSelectParent(obj, tf)
            set(obj.parentPopupMenu, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function p = getSelectedParent(obj)
            p = get(obj.parentPopupMenu, 'Value');
        end

        function setSelectedParent(obj, p)
            set(obj.parentPopupMenu, 'Value', p);
        end
        
        function setParentList(obj, names, values)
            set(obj.parentPopupMenu, 'String', names);
            set(obj.parentPopupMenu, 'Values', values);
        end
        
        function t = getSelectedTemplate(obj)
            t = get(obj.templatePopupMenu, 'Value');
        end
        
        function setSelectedTemplate(obj, t)
            set(obj.templatePopupMenu, 'Value', t);
        end
        
        function setTemplateList(obj, names, values)
            set(obj.templatePopupMenu, 'String', names);
            set(obj.templatePopupMenu, 'Values', values);
        end

    end

end
