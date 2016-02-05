function root = javaTree(m)
    root = javax.swing.tree.DefaultMutableTreeNode();
    addNodes(root, m);
end

function addNodes(root, m)
    keys = m.keys;
    for i = 1 : numel(keys)
        value = m(keys{i});
        node = javax.swing.tree.DefaultMutableTreeNode(keys{i}, ~isempty(value));
        root.add(node);
        for k = 1 : numel(value)
            if isa(value{k}, 'containers.Map')
                addNodes(node, value{k});
            else
                node.add(javax.swing.tree.DefaultMutableTreeNode(value{k}, false));
            end
        end
    end
end

