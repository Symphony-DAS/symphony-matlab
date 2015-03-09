package UIExtrasTree;

import java.awt.Component;
import javax.swing.JComponent;
import javax.swing.JTree;
import javax.swing.tree.DefaultTreeCellRenderer;

/**
 Note: add this com.jidesoft file to the compile time libraries:
 * <matlabroot>\R2012b\java\jarext\jide\jide-common.jar
 * Copyright 2012-2014 The MathWorks, Inc.
 * @author rjackey
 */
public class CheckBoxTreeCellRenderer extends com.jidesoft.swing.CheckBoxTreeCellRenderer {
    
    public CheckBoxTreeCellRenderer() {
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
        
        DefaultTreeCellRenderer renderer = (DefaultTreeCellRenderer) tree.getCellRenderer();
        renderer.setLeafIcon(node.Icon);
        renderer.setOpenIcon(node.Icon);
        renderer.setOpenIcon(node.Icon);
        this.setToolTipText(node.TooltipString);

        JComponent treeCellRendererComponent = (JComponent) _actualTreeRenderer.getTreeCellRendererComponent(
                tree, value, sel,
                expanded, leaf, row,
                hasFocus);
        
        return treeCellRendererComponent;
    }
}
