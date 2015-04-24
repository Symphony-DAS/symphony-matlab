function i = getRowIndex(table, key)
    jmodel = table.getTable().getModel();
    count = jmodel.getRowCount;
    for i = 0:count-1
        row = jmodel.getValueAt(i, 0);
        if strcmp(row, key)
            break;
        end
    end
end

