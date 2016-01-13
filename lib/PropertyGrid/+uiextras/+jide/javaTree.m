function root = javaTree(str)
    root = javax.swing.tree.DefaultMutableTreeNode();
    fields = fieldnames(str);
    for i = 1 : numel(fields)
        value = str.(fields{i});
        folder = javax.swing.tree.DefaultMutableTreeNode(fields{i}, true);
        root.add(folder);
        for k = 1 : numel(value)
            node = javax.swing.tree.DefaultMutableTreeNode(value{k}, false);
            folder.add(node);
        end
    end
end

