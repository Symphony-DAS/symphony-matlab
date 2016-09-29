classdef SplitEpochGroupView < appbox.View
    
    events
        SelectedGroup
        Split
        Cancel
    end
    
    properties (Access = private)
        groupPopupMenu
        blockPopupMenu
        spinner
        splitButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Split Epoch Group', ...
                'Position', screenCenter(300, 109));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            splitLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', splitLayout, ...
                'String', 'Split:');
            Label( ...
                'Parent', splitLayout, ...
                'String', 'After block:');
            obj.groupPopupMenu = MappedPopupMenu( ...
                'Parent', splitLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SelectedGroup'));
            obj.blockPopupMenu = MappedPopupMenu( ...
                'Parent', splitLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(splitLayout, ...
                'Widths', [65 -1], ...
                'Heights', [23 23]);
            
            % Split/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            spinnerLayout = uix.VBox( ...
                'Parent', controlsLayout);
            uix.Empty('Parent', spinnerLayout);
            obj.spinner = com.mathworks.widgets.BusyAffordance();
            javacomponent(obj.spinner.getComponent(), [], spinnerLayout);
            set(spinnerLayout, 'Heights', [4 -1]);
            uix.Empty('Parent', controlsLayout);
            obj.splitButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Split', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Split'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [16 -1 75 75]);

            set(mainLayout, 'Heights', [-1 23]);

            % Set split button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.splitButton);
            end
        end
        
        function enableSplit(obj, tf)
            set(obj.splitButton, 'Enable', appbox.onOff(tf));
        end
        
        function tf = getEnableSplit(obj)
            tf = appbox.onOff(get(obj.splitButton, 'Enable'));
        end
        
        function enableCancel(obj, tf)
            set(obj.cancelButton, 'Enable', appbox.onOff(tf));
        end
        
        function enableSelectGroup(obj, tf)
            set(obj.groupPopupMenu, 'Enable', appbox.onOff(tf));
        end

        function g = getSelectedGroup(obj)
            g = get(obj.groupPopupMenu, 'Value');
        end

        function setSelectedGroup(obj, g)
            set(obj.groupPopupMenu, 'Value', g);
        end

        function l = getGroupList(obj)
            l = get(obj.groupPopupMenu, 'Values');
        end

        function setGroupList(obj, names, values)
            set(obj.groupPopupMenu, 'String', names);
            set(obj.groupPopupMenu, 'Values', values);
        end
        
        function enableSelectBlock(obj, tf)
            set(obj.blockPopupMenu, 'Enable', appbox.onOff(tf));
        end

        function b = getSelectedBlock(obj)
            b = get(obj.blockPopupMenu, 'Value');
        end

        function setSelectedBlock(obj, b)
            set(obj.blockPopupMenu, 'Value', b);
        end

        function l = getBlockList(obj)
            l = get(obj.blockPopupMenu, 'Values');
        end

        function setBlockList(obj, names, values)
            set(obj.blockPopupMenu, 'String', names);
            set(obj.blockPopupMenu, 'Values', values);
        end
        
        function startSpinner(obj)
            obj.spinner.start();
        end
        
        function stopSpinner(obj)
            obj.spinner.stop();
        end
        
    end
    
end

