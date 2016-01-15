package UIExtrasPropertyGrid;

import com.jidesoft.combobox.TreeChooserPanel;
import com.jidesoft.combobox.TreeExComboBox;
import com.jidesoft.grid.TreeComboBoxCellEditor;

import javax.swing.*;
import javax.swing.tree.TreeModel;
import javax.swing.tree.TreeNode;

/**
 * Created by Client Admin on 1/14/2016.
 */
public class RootlessTreeComboBoxCellEditor extends TreeComboBoxCellEditor {

    public RootlessTreeComboBoxCellEditor(TreeNode treeNode, boolean b) {
        super(treeNode, b);
    }

    protected TreeExComboBox createTreeComboBox() {
        return new TreeExComboBox() {
            protected TreeChooserPanel createTreeChooserPanel(TreeModel model) {
                return new TreeChooserPanel(model) {
                    protected void setupTree(final JTree tree) {
                        super.setupTree(tree);
                        tree.setRootVisible(false);
                        tree.setShowsRootHandles(true);
                    }
                };
            }
        };
    }
}
