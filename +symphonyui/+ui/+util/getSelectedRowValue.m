function v = getSelectedRowValue(table)
    jtable = table.getTable();
    row = jtable.getSelectedRow();
    if row == -1
        v = [];
    else
        v = jtable.getModel().getValueAt(row, 0);
    end
end

