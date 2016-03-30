classdef ProtocolPresetsView < appbox.View
    
    events
        SelectedProtocolPreset
        ApplyProtocolPreset
        ViewOnlyProtocolPreset
        RecordProtocolPreset
        AddProtocolPreset
        RemoveProtocolPreset
    end
    
    properties (Access = private)
        presetsTable
        addButton
        removeButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
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
                'RowHeight', 40, ...
                'BorderType', 'none', ...
                'ShowVerticalLines', 'off', ...
                'Focusable', 'off', ...
                'Editable', 'off', ...
                'CellSelectionCallback', @(h,d)notify(obj, 'SelectedProtocolPreset'));
            
            % Presets toolbar.
            presetsToolbarLayout = uix.HBox( ...
                'Parent', mainLayout);
            uix.Empty('Parent', presetsToolbarLayout);
            obj.addButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/add.png'), ...
                'Callback', @(h,d)notify(obj, 'AddProtocolPreset'));
            obj.removeButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/remove.png'), ...
                'Callback', @(h,d)notify(obj, 'RemoveProtocolPreset'));
            set(presetsToolbarLayout, 'Widths', [-1 22 22]);
            
            set(mainLayout, 'Heights', [-1 22]);
        end
        
        function show(obj)
            show@appbox.View(obj);
            set(obj.presetsTable, 'ColumnHeaderVisible', false);
        end
        
        function enableApplyProtocolPreset(obj, tf)
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                d = data{i, 2};
                d{2} = tf;
                data{i, 2} = d;
            end
            set(obj.presetsTable, 'Data', data);
        end
        
        function enableViewOnlyProtocolPreset(obj, tf)
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                d = data{i, 3};
                d{2} = tf;
                data{i, 3} = d;
            end
            set(obj.presetsTable, 'Data', data);
        end
        
        function enableRecordProtocolPreset(obj, tf)
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                d = data{i, 4};
                d{2} = tf;
                data{i, 4} = d;
            end
            set(obj.presetsTable, 'Data', data);
        end
        
        function setProtocolPresets(obj, data)
            import symphonyui.app.App;
            
            d = cell(size(data, 1), 4);
            for i = 1:size(d, 1)
                d{i, 1} = toHtml(data{i, 1}, data{i, 2});
                d{i, 2} = {App.getResource('icons/apply.png'), true};
                d{i, 3} = {App.getResource('icons/view_only.png'), true};
                d{i, 4} = {App.getResource('icons/record.png'), false};
            end
            set(obj.presetsTable, 'Data', d);
        end
        
        function d = getProtocolPresets(obj)
            presets = obj.presetsTable.getColumnData(1);
            d = cell(numel(presets), 2);
            for i = 1:size(d, 1)
                [name, protocolId] = fromHtml(presets{i});
                d{i, 1} = name;
                d{i, 2} = protocolId;
            end
        end
        
        function addProtocolPreset(obj, name, protocolId)
            import symphonyui.app.App;
            
            obj.presetsTable.addRow({toHtml(name, protocolId), ...
                {App.getResource('icons/apply.png'), false}, ...
                {App.getResource('icons/view_only.png'), false}, ...
                {App.getResource('icons/record.png'), false}});
        end
        
        function removeProtocolPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(fromHtml(c), name), presets));
            obj.presetsTable.removeRow(index); %#ok<FNDSB>
        end
        
        function n = getSelectedProtocolPreset(obj)
            rows = get(obj.presetsTable, 'SelectedRows');
            if isempty(rows)
                n = [];
            else
                n = fromHtml(obj.presetsTable.getValueAt(rows(1), 1));
            end
        end
        
        function setSelectedProtocolPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(fromHtml(c), name), presets));
            set(obj.presetsTable, 'SelectedRows', index);
        end
        
    end
    
end

function html = toHtml(name, protocolId)
    html = ['<html>' name '<br><font color="gray">' protocolId '</font></html>'];
end

function [name, protocolId] = fromHtml(html)
    split = strsplit(html, {'<', '>'});
    name = split{3};
    protocolId = split{6};
end

