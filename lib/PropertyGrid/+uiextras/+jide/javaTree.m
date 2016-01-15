function root = javaTree(s)
    root = javax.swing.tree.DefaultMutableTreeNode('root');
    addNodes(root, s);
end

function addNodes(root, s)
    fields = fieldnames(s);
    for i = 1 : numel(fields)
        value = s.(fields{i});
        node = javax.swing.tree.DefaultMutableTreeNode(fields{i}, ~isempty(value));
        root.add(node);
        for k = 1 : numel(value)
            if isstruct(value{k})
                addNodes(node, value{k});
            else
                node.add(javax.swing.tree.DefaultMutableTreeNode(value{k}, false));
            end
        end
    end
end

