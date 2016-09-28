classdef MergeEpochGroupsView < appbox.View
    
    events
        SelectedGroup1
        Merge
        Cancel
    end
    
    properties (Access = private)
        group1PopupMenu
        group2PopupMenu
        mergeButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Merge Epoch Groups', ...
                'Position', screenCenter(300, 109));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);
            
            mergeLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', mergeLayout, ...
                'String', 'Group 1:');
            Label( ...
                'Parent', mergeLayout, ...
                'String', 'Group 2:');
            obj.group1PopupMenu = MappedPopupMenu( ...
                'Parent', mergeLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SelectedGroup1'));
            obj.group2PopupMenu = MappedPopupMenu( ...
                'Parent', mergeLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(mergeLayout, ...
                'Widths', [50 -1], ...
                'Heights', [23 23]);
            
            % Merge/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.mergeButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Merge', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Merge'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 23]);

            % Set merge button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.mergeButton);
            end
        end
        
        function enableMerge(obj, tf)
            set(obj.mergeButton, 'Enable', appbox.onOff(tf));
        end
        
        function tf = getEnableMerge(obj)
            tf = appbox.onOff(get(obj.mergeButton, 'Enable'));
        end
        
        function enableSelectGroup1(obj, tf)
            set(obj.group1PopupMenu, 'Enable', appbox.onOff(tf));
        end

        function g = getSelectedGroup1(obj)
            g = get(obj.group1PopupMenu, 'Value');
        end

        function setSelectedGroup1(obj, g)
            set(obj.group1PopupMenu, 'Value', g);
        end

        function l = getGroup1List(obj)
            l = get(obj.group1PopupMenu, 'Values');
        end

        function setGroup1List(obj, names, values)
            set(obj.group1PopupMenu, 'String', names);
            set(obj.group1PopupMenu, 'Values', values);
        end
        
        function enableSelectGroup2(obj, tf)
            set(obj.group2PopupMenu, 'Enable', appbox.onOff(tf));
        end

        function g = getSelectedGroup2(obj)
            g = get(obj.group2PopupMenu, 'Value');
        end

        function setSelectedGroup2(obj, g)
            set(obj.group2PopupMenu, 'Value', g);
        end

        function l = getGroup2List(obj)
            l = get(obj.group2PopupMenu, 'Values');
        end

        function setGroup2List(obj, names, values)
            set(obj.group2PopupMenu, 'String', names);
            set(obj.group2PopupMenu, 'Values', values);
        end
        
    end
    
end

