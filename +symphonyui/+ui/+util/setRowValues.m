function setRowValues(table, values)
    jtable = table.getTable();
    jmodel = jtable.getModel();
    jmodel.setRowCount(0);
    for i = 1:numel(values)
        jmodel.addRow(values{i});
    end
    jtable.clearSelection();
end
