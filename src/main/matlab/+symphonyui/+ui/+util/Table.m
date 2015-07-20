% A better uitable.

classdef Table < matlab.mixin.SetGet %#ok<*MCSUP>
    
    properties
        Data
        ColumnName
        ColumnWidth
        Enable
        Editable
    end
    
    properties (SetAccess = private)
        SelectedRow
    end
    
    properties (Access = private)
        Control
    end
    
    methods
        
        function obj = Table(varargin)
            p = inputParser();
            p.KeepUnmatched = true;
            p.addOptional('Parent', get(groot, 'CurrentFigure'));
            p.addOptional('ColumnName', {'A','B','C'});
            p.parse(varargin{:});
            obj.Control = createTable( ...
                'Parent', p.Results.Parent, ...
                'Container', p.Results.Parent, ...
                'Headers', p.Results.ColumnName, ...
                'SelectionMode', javax.swing.ListSelectionModel.SINGLE_SELECTION, ...
                'Buttons', 'off');
            obj.Control.getTableScrollPane.getRowHeader.setVisible(0);
            obj.Control.getTableScrollPane.setBorder(javax.swing.BorderFactory.createEmptyBorder());
            obj.Control.getTable.getTableHeader.setToolTipText([]);
            obj.Control.getTable.setFillsViewportHeight(true);
            obj.set(p.Unmatched);
        end
        
        function d = get.Data(obj)
            jtable = obj.Control.getTable();
            jmodel = jtable.getModel();
            nRows = jmodel.getRowCount();
            nColumns = jmodel.getColumnCount();
            d = cell(1, nRows);
            for row = 1:nRows
                value = cell(1, nColumns);
                for col = 1:nColumns
                    value{col} = jmodel.getValueAt(row - 1, col - 1);
                end
                d{row} = value;
            end
        end
        
        function set.Data(obj, data)
            jtable = obj.Control.getTable();
            jmodel = jtable.getModel();
            jmodel.setRowCount(0);
            for i = 1:numel(data)
                jmodel.addRow(data{i});
            end
            jtable.clearSelection();
        end
        
        function n = get.ColumnName(obj)
            n = get(obj.Control, 'ColumnName');
        end
        
        function set.ColumnName(obj, n)
            set(obj.Control, 'ColumnName', n);
        end
        
        function w = get.ColumnWidth(obj)
            model = obj.Control.getTable().getColumnModel();
            nColumns = model.getColumnCount();
            w = cell(1, nColumns);
            for i = 1:nColumns
                w{i} = model.getColumn(i - 1).getWidth();
            end
        end
        
        function set.ColumnWidth(obj, widths)
            model = obj.Control.getTable().getColumnModel();
            nWidths = numel(widths);
            for i = 1:nWidths
                model.getColumn(i - 1).setMaxWidth(widths{i});
            end
        end
        
        function i = get.SelectedRow(obj)
            i = obj.Control.getTable().getSelectedRow() + 1;
        end
        
        function e = get.Enable(obj)
            jtable = obj.Control.getTable();
            e = symphonyui.ui.util.onOff(jtable.getEnabled());
        end
        
        function set.Enable(obj, e)
            jtable = obj.Control.getTable();
            if strcmpi(e, 'on')
                jtable.setEnabled(true);
            else
                jtable.setEnabled(false);
            end
        end
        
        function tf = get.Editable(obj)
            tf = get(obj.Control, 'Editable');
        end
        
        function set.Editable(obj, tf)
            set(obj.Control, 'Editable', tf);
        end
        
        function addRow(obj, rowData)
            jtable = obj.Control.getTable();
            jtable.getModel().addRow(rowData);
            jtable.clearSelection();
        end
        
        function removeRow(obj, index)
            jtable = obj.Control.getTable();
            jtable.getModel().removeRow(index - 1);
            jtable.clearSelection();
        end
        
        function v = getValueAt(obj, row, col)
            if row <= 0
                v = [];
                return;
            end
            v = obj.Control.getTable().getModel().getValueAt(row - 1, col - 1);
        end
        
        function d = getColumnData(obj, col)
            jtable = obj.Control.getTable();
            jmodel = jtable.getModel();
            nRows = jmodel.getRowCount();
            d = cell(nRows, 1);
            for row = 1:nRows
                d{row, 1} = jmodel.getValueAt(row - 1, col - 1);
            end
        end
        
    end
    
end

