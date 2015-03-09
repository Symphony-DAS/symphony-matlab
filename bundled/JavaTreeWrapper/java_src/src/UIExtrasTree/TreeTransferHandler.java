package UIExtrasTree;

import UIExtrasTree.TreeNode;
import java.awt.datatransfer.*;
import java.util.*;
import javax.swing.*;
import javax.swing.tree.*;

/**
 * Copyright 2012-2014 The MathWorks, Inc.
 * @author rjackey
 */
public class TreeTransferHandler extends TransferHandler {

    DataFlavor nodesFlavor;
    DataFlavor[] flavors = new DataFlavor[1];

    public TreeTransferHandler() throws ClassNotFoundException {
        String mimeType;
        mimeType = DataFlavor.javaJVMLocalObjectMimeType + ";class=\""
                + javax.swing.tree.DefaultMutableTreeNode[].class.getName() + "\"";
        nodesFlavor = new DataFlavor(mimeType);
        flavors[0] = nodesFlavor;
    }

    @Override
    protected Transferable createTransferable(JComponent c) {
        JTree tree = (JTree) c;
        TreePath[] paths = tree.getSelectionPaths();
        if (paths != null) {
            // Make up a node array for transfer
            List<TreeNode> nodeList =
                    new ArrayList<TreeNode>();
            TreeNode node =
                    (TreeNode) paths[0].getLastPathComponent();
            nodeList.add(node);
            for (int i = 1; i < paths.length; i++) {
                TreeNode next =
                        (TreeNode) paths[i].getLastPathComponent();
                // Do not allow higher level nodes to be added to list.  
                if (next.getLevel() < node.getLevel()) {
                    break;
                } else if (next.getLevel() > node.getLevel()) {  // child node  
                    nodeList.add(next);
                    // node already contains child  
                } else {                                        // sibling  
                    nodeList.add(next);
                }
            }
            TreeNode[] nodes =
                    nodeList.toArray(new TreeNode[nodeList.size()]);
            return new NodesTransferable(nodes);
        }
        return null;
    }

    @Override
    public int getSourceActions(JComponent c) {
        return COPY_OR_MOVE;
    }

    public class NodesTransferable implements Transferable {

        TreeNode[] nodes;

        public NodesTransferable(TreeNode[] nodes) {
            this.nodes = nodes;
        }

        @Override
        public Object getTransferData(DataFlavor flavor) throws UnsupportedFlavorException {
            if (!isDataFlavorSupported(flavor)) {
                throw new UnsupportedFlavorException(flavor);
            }
            return nodes;
        }

        @Override
        public DataFlavor[] getTransferDataFlavors() {
            return flavors;
        }

        @Override
        public boolean isDataFlavorSupported(DataFlavor flavor) {
            return nodesFlavor.equals(flavor);
        }
    }
}
