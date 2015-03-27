/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package UIExtrasTree;

import javax.swing.tree.TreePath;

/**
 * Copyright 2012-2014 The MathWorks, Inc.
 * @author rjackey
 */
public class CheckBoxTree extends com.jidesoft.swing.CheckBoxTree {
    
    /* CONSTRUCTORS */
    
    public CheckBoxTree() {
        super();
    }

    public CheckBoxTree(TreeNode root)  {
        super(root);
    }

    public CheckBoxTree(TreeNode root, boolean allowsChildren) {
        super(root, allowsChildren);
    }
    
    /* METHODS */
    
    @Override
    public boolean isCheckBoxVisible(TreePath path) {
        return ((TreeNode) path.getLastPathComponent()).getCheckBoxVisible();
    }

    @Override
    public boolean isCheckBoxEnabled(TreePath path) {
        return ((TreeNode) path.getLastPathComponent()).getCheckBoxEnabled();
    }
    
}
