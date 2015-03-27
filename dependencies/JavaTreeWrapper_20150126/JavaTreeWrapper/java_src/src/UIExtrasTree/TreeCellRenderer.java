/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package UIExtrasTree;

/**
 * Copyright 2012-2014 The MathWorks, Inc.
 * @author rjackey
 */
import java.awt.Component;
import javax.swing.JTree;
import javax.swing.tree.DefaultTreeCellRenderer;

public class TreeCellRenderer extends DefaultTreeCellRenderer {
    
    public TreeCellRenderer() {
    }
    
    @Override
    public Component getTreeCellRendererComponent(
            JTree tree,
            Object value,
            boolean sel,
            boolean expanded,
            boolean leaf,
            int row,
            boolean hasFocus) {
        
        TreeNode node = (TreeNode) value;
        this.setLeafIcon(node.Icon);
        this.setOpenIcon(node.Icon);
        this.setClosedIcon(node.Icon);
        this.setToolTipText(node.TooltipString);
        
        return super.getTreeCellRendererComponent(
                tree, value, sel,
                expanded, leaf, row,
                hasFocus);
    }
}
