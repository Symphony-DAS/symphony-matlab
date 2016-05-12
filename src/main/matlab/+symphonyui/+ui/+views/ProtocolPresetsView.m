classdef ProtocolPresetsView < appbox.View

    events
        ApplyProtocolPreset
        ViewOnlyProtocolPreset
        RecordProtocolPreset
        StopProtocolPreset
        AddProtocolPreset
        RemoveProtocolPreset
    end

    properties (Access = private)
        presetsTable
        applyButton
        viewOnlyButton
        recordButton
        stopButton
        addButton
        removeButton
    end

    methods

        function createUi(obj)
            import appbox.*;
            import symphonyui.app.App;

            set(obj.figureHandle, ...
                'Name', 'Protocol Presets', ...
                'Position', screenCenter(360, 200));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Spacing', 1);

            obj.presetsTable = uiextras.jTable.Table( ...
                'Parent', mainLayout, ...
                'ColumnName', {'Preset', 'Apply', 'View Only', 'Record'}, ...
                'ColumnFormat', {'', 'button', 'button', 'button'}, ...
                'ColumnFormatData', ...
                    {{}, ...
                    @(h,d)notify(obj, 'ApplyProtocolPreset', symphonyui.ui.UiEventData(d.getSource())), ...
                    @(h,d)notify(obj, 'ViewOnlyProtocolPreset', symphonyui.ui.UiEventData(d.getSource())), ...
                    @(h,d)notify(obj, 'RecordProtocolPreset', symphonyui.ui.UiEventData(d.getSource()))}, ...
                'ColumnMinWidth', [0 40 40 40], ...
                'ColumnMaxWidth', [java.lang.Integer.MAX_VALUE 40 40 40], ...
                'Data', {}, ...
                'UserData', struct('applyEnabled', false, 'viewOnlyEnabled', false, 'recordEnabled', false), ...
                'RowHeight', 40, ...
                'BorderType', 'none', ...
                'ShowVerticalLines', 'off', ...
                'Focusable', 'off', ...
                'Editable', 'off');

            obj.applyButton.icon = App.getResource('icons', 'apply.png');
            obj.applyButton.tooltip = 'Apply Protocol Preset';

            obj.viewOnlyButton.icon = App.getResource('icons', 'view_only.png');
            obj.viewOnlyButton.tooltip = 'View Only Protocol Preset';

            obj.recordButton.icon = App.getResource('icons', 'record.png');
            obj.recordButton.tooltip = 'Record Protocol Preset';

            % Presets toolbar.
            presetsToolbarLayout = uix.HBox( ...
                'Parent', mainLayout);
            obj.stopButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'stop_small.png'), ...
                'TooltipString', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'StopProtocolPreset'));
            uix.Empty('Parent', presetsToolbarLayout);
            obj.addButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'add.png'), ...
                'TooltipString', 'Add Protocol Preset...', ...
                'Callback', @(h,d)notify(obj, 'AddProtocolPreset'));
            obj.removeButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'remove.png'), ...
                'TooltipString', 'Remove Protocol Preset', ...
                'Callback', @(h,d)notify(obj, 'RemoveProtocolPreset'));
            set(presetsToolbarLayout, 'Widths', [22 -1 22 22]);

            set(mainLayout, 'Heights', [-1 22]);
        end

        function show(obj)
            show@appbox.View(obj);
            set(obj.presetsTable, 'ColumnHeaderVisible', false);
        end

        function enableApplyProtocolPreset(obj, tf)
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                data{i, 2} = {obj.applyButton.icon, obj.applyButton.tooltip, tf};
            end
            set(obj.presetsTable, 'Data', data);
            
            enables = get(obj.presetsTable, 'UserData');
            enables.applyEnabled = tf;
            set(obj.presetsTable, 'UserData', enables);
        end
        
        function stopEditingApplyProtocolPreset(obj)
            [~, editor] = obj.presetsTable.getRenderer(2);
            editor.stopCellEditing();
        end

        function enableViewOnlyProtocolPreset(obj, tf)                        
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                data{i, 3} = {obj.viewOnlyButton.icon, obj.viewOnlyButton.tooltip, tf};
            end
            set(obj.presetsTable, 'Data', data);
            
            enables = get(obj.presetsTable, 'UserData');
            enables.viewOnlyEnabled = tf;
            set(obj.presetsTable, 'UserData', enables);
        end
        
        function stopEditingViewOnlyProtocolPreset(obj)
            [~, editor] = obj.presetsTable.getRenderer(3);
            editor.stopCellEditing();
        end

        function enableRecordProtocolPreset(obj, tf)
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                data{i, 4} = {obj.recordButton.icon, obj.recordButton.tooltip, tf};
            end
            set(obj.presetsTable, 'Data', data);

            enables = get(obj.presetsTable, 'UserData');
            enables.recordEnabled = tf;
            set(obj.presetsTable, 'UserData', enables);
        end
        
        function stopEditingRecordProtocolPreset(obj)
            [~, editor] = obj.presetsTable.getRenderer(4);
            editor.stopCellEditing();
        end

        function enableStopProtocolPreset(obj, tf)
            set(obj.stopButton, 'Enable', appbox.onOff(tf));
        end

        function setProtocolPresets(obj, data)
            enables = get(obj.presetsTable, 'UserData');
            d = cell(size(data, 1), 4);
            for i = 1:size(d, 1)
                d{i, 1} = toDisplayName(data{i, 1}, data{i, 2});
                d{i, 2} = {obj.applyButton.icon, obj.applyButton.tooltip, enables.applyEnabled};
                d{i, 3} = {obj.viewOnlyButton.icon, obj.viewOnlyButton.tooltip, enables.viewOnlyEnabled};
                d{i, 4} = {obj.recordButton.icon, obj.recordButton.tooltip, enables.recordEnabled};
            end
            set(obj.presetsTable, 'Data', d);
        end

        function d = getProtocolPresets(obj)
            presets = obj.presetsTable.getColumnData(1);
            d = cell(numel(presets), 2);
            for i = 1:size(d, 1)
                [name, protocolId] = fromDisplayName(presets{i});
                d{i, 1} = name;
                d{i, 2} = protocolId;
            end
        end

        function addProtocolPreset(obj, name, protocolId)
            enables = get(obj.presetsTable, 'UserData');
            obj.presetsTable.addRow({toDisplayName(name, protocolId), ...
                {obj.applyButton.icon, obj.applyButton.tooltip, enables.applyEnabled}, ...
                {obj.viewOnlyButton.icon, obj.viewOnlyButton.tooltip, enables.viewOnlyEnabled}, ...
                {obj.recordButton.icon, obj.recordButton.tooltip, enables.recordEnabled}});
        end

        function removeProtocolPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(fromDisplayName(c), name), presets));
            obj.presetsTable.removeRow(index); %#ok<FNDSB>
        end

        function n = getSelectedProtocolPreset(obj)
            rows = get(obj.presetsTable, 'SelectedRows');
            if isempty(rows)
                n = [];
            else
                n = fromDisplayName(obj.presetsTable.getValueAt(rows(1), 1));
            end
        end

        function setSelectedProtocolPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(fromDisplayName(c), name), presets));
            set(obj.presetsTable, 'SelectedRows', index);
        end

    end

end

function html = toDisplayName(name, protocolId)
    html = ['<html>' name '<br><font color="gray">' protocolId '</font></html>'];
end

function [name, protocolId] = fromDisplayName(html)
    split = regexprep(html, '<br>', '\n');
    split = regexprep(split, '<.*?>', '');
    split = strsplit(split, '\n');
    name = split{1};
    protocolId = split{2};
end
