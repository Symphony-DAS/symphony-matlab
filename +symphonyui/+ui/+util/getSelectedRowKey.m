function k = getSelectedRowKey(table)
    jtable = table.getTable();
    row = jtable.getSelectedRow();
    if row == -1
        k = [];
    else
        k = jtable.getModel().getValueAt(row, 0);
    end
end

