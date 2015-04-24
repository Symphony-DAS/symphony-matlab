function addRowValue(table, value)
    if ~iscell(value)
        value = {value};
    end
    jtable = table.getTable();
    jtable.getModel().addRow(value);
    jtable.clearSelection();
    jtable.scrollRectToVisible(jtable.getCellRect(jtable.getRowCount()-1, 0, true));
end
