classdef EntityPresetsView < appbox.View

    events
        RemoveEntityPreset
        Ok
    end

    properties (Access = private)
        presetsTable
        removeButton
        okButton
    end

    methods

        function createUi(obj)
            import appbox.*;
            import symphonyui.app.App;

            set(obj.figureHandle, ...
                'Name', 'Entity Presets', ...
                'Position', screenCenter(240, 200));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Spacing', 1);

            obj.presetsTable = uiextras.jTable.Table( ...
                'Parent', mainLayout, ...
                'ColumnName', {'Preset', 'Remove'}, ...
                'ColumnFormat', {'', 'button'}, ...
                'ColumnFormatData', ...
                    {{}, ...
                    @(h,d)notify(obj, 'RemoveEntityPreset', symphonyui.ui.UiEventData(d.getSource()))}, ...
                'ColumnMinWidth', [0 30], ...
                'ColumnMaxWidth', [java.lang.Integer.MAX_VALUE 30], ...
                'Data', {}, ...
                'RowHeight', 30, ...
                'BorderType', 'none', ...
                'ShowVerticalLines', 'off', ...
                'Focusable', 'off', ...
                'Editable', 'off');

            obj.removeButton.icon = App.getResource('icons', 'remove.png');
            obj.removeButton.tooltip = 'Remove Entity Preset';

            % OK control.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7, ...
                'Padding', 11);
            uiextras.Empty('Parent', controlsLayout);
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            set(controlsLayout, 'Sizes', [-1 75]);

            set(mainLayout, 'Heights', [-1 45]);

            % Set add button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end

        function show(obj)
            show@appbox.View(obj);
            set(obj.presetsTable, 'ColumnHeaderVisible', false);
        end

        function setEntityPresets(obj, data)
            d = cell(size(data, 1), 2);
            for i = 1:size(d, 1)
                d{i, 1} = data{i, 1};
                d{i, 2} = {obj.removeButton.icon, obj.removeButton.tooltip, true};
            end
            set(obj.presetsTable, 'Data', d);
        end

        function d = getEntityPresets(obj)
            presets = obj.presetsTable.getColumnData(1);
            d = cell(numel(presets), 2);
            for i = 1:size(d, 1)
                d{i, 1} = presets{i};
            end
        end

        function removeEntityPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(c, name), presets));
            obj.presetsTable.removeRow(index); %#ok<FNDSB>
        end

    end

end
