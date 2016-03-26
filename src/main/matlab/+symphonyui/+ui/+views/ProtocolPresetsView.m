classdef ProtocolPresetsView < appbox.View
    
    events
        SelectedProtocolPreset
        ViewOnlyProtocolPreset
        RecordProtocolPreset
        ApplyProtocolPreset
        AddProtocolPreset
        RemoveProtocolPreset
    end
    
    properties (Access = private)
        presetsTable
        viewOnlyButton
        recordButton
        applyButton
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
                'ColumnName', {'Preset'}, ...
                'Data', {}, ...
                'RowHeight', 40, ...
                'BorderType', 'none', ...
                'Editable', 'off', ...
                'CellSelectionCallback', @(h,d)notify(obj, 'SelectedProtocolPreset'));
            
            % Presets toolbar.
            presetsToolbarLayout = uix.HBox( ...
                'Parent', mainLayout);
            obj.viewOnlyButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/view_only.png'), ...
                'Callback', @(h,d)notify(obj, 'ViewOnlyProtocolPreset'));
            obj.recordButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/record.png'), ...
                'Callback', @(h,d)notify(obj, 'RecordProtocolPreset'));
            obj.applyButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/apply.png'), ...
                'Callback', @(h,d)notify(obj, 'ApplyProtocolPreset'));
            uix.Empty('Parent', presetsToolbarLayout);
            obj.addButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/add.png'), ...
                'Callback', @(h,d)notify(obj, 'AddProtocolPreset'));
            obj.removeButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/remove.png'), ...
                'Callback', @(h,d)notify(obj, 'RemoveProtocolPreset'));
            set(presetsToolbarLayout, 'Widths', [22 22 22 -1 22 22]);
            
            set(mainLayout, 'Heights', [-1 22]);
        end
        
        function show(obj)
            show@appbox.View(obj);
            set(obj.presetsTable, 'ColumnHeaderVisible', false);
        end
        
        function enableViewOnlyProtocolPreset(obj, tf)
            set(obj.viewOnlyButton, 'Enable', appbox.onOff(tf));
        end
        
        function enableRecordProtocolPreset(obj, tf)
            set(obj.recordButton, 'Enable', appbox.onOff(tf));
        end
        
        function enableApplyProtocolPreset(obj, tf)
            set(obj.applyButton, 'Enable', appbox.onOff(tf));
        end
        
        function setProtocolPresets(obj, data)
            d = cell(size(data, 1), 1);
            for i = 1:numel(d)
                d{i} = ['<html>' data{i, 1} '<br>' ...
                    '<font color="gray">' data{i, 2} '</font></html>'];
            end
            set(obj.presetsTable, 'Data', d);
        end
        
        function addProtocolPreset(obj, name, protocolId)
            obj.presetsTable.addRow(['<html>' name '<br>' ...
                '<font color="gray">' protocolId '</font></html>']);
        end
        
        function removeProtocolPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(c, name), presets));
            obj.presetsTable.removeRow(index); %#ok<FNDSB>
        end
        
        function n = getSelectedProtocolPreset(obj)
            rows = get(obj.presetsTable, 'SelectedRows');
            if isempty(rows)
                n = [];
            else
                n = obj.presetsTable.getValueAt(rows(1), 1);
            end
        end
        
    end
    
end

