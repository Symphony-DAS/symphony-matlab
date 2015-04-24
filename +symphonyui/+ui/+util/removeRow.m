function removeRow(table, key)
    i = symphonyui.ui.util.getRowIndex(table, key);
    table.getTable().getModel().removeRow(i);
end
