function removeRowValue(table, value)
    jmodel = table.getTable().getModel();
    count = jmodel.getRowCount;
    for i = 1:count
        row = jmodel.getValueAt(i-1, 0);
        if strcmp(row, value)
            jmodel.removeRow(i-1);
            break;
        end
    end
end
