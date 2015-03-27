/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package UIExtrasTree;

/**
 * Copyright 2012-2014 The MathWorks, Inc.
 * @author rjackey
 */
import javax.swing.Icon;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.TreePath;

public class TreeNode extends DefaultMutableTreeNode {

    Icon Icon;
    String TooltipString;
    boolean CheckBoxEnabled = true;
    boolean CheckBoxVisible = true;

    
    /* CONSTRUCTORS */
    
    public TreeNode() {
        super();
        Icon = null;
        TooltipString = null;
    }

    public TreeNode(Object userObject) {
        super(userObject);
        Icon = null;
        TooltipString = null;
    }

    public TreeNode(Object userObject, boolean allowsChildren) {
        super(userObject,allowsChildren);
        Icon = null;
        TooltipString = null;
    }
    
    /* METHODS */
    
    public TreePath getTreePath() {
        return new TreePath(this.getPath());
    }
    
    public Icon getIcon() {
        return this.Icon;
    }

    public void setIcon(Icon icon) {
        this.Icon = icon;
    }

    public String getTooltipString() {
        return this.TooltipString;
    }

    public void setTooltipString(String value) {
        this.TooltipString = value;
    }
    
    public boolean getCheckBoxEnabled() {
        return this.CheckBoxEnabled;
    }
    
    public void setCheckBoxEnabled(boolean value) {
        this.CheckBoxEnabled = value;
    }
    
    public boolean getCheckBoxVisible() {
        return this.CheckBoxVisible;
    }
    
    public void setCheckBoxVisible(boolean value) {
        this.CheckBoxVisible = value;
    }

}
