package UIExtrasTable;

import com.jidesoft.converter.ConverterContext;
import com.jidesoft.converter.ObjectConverter;
import com.jidesoft.grid.ButtonTableCellEditorRenderer;
import com.mathworks.mwswing.MJButton;

import javax.swing.*;
import java.awt.*;

public class MButtonTableCellEditorRenderer extends ButtonTableCellEditorRenderer {

    public MButtonTableCellEditorRenderer() {
    }

    public MButtonTableCellEditorRenderer(ConverterContext context) {
        super(context);
    }

    public Component createTableCellEditorRendererComponent(JTable table, int row, int column) {
        MJButton button = new MJButton();
        button.setContentAreaFilled(true);
        button.setOpaque(true);
        button.setFocusable(false);
        button.setRequestFocusEnabled(false);
        button.setFlyOverAppearance(true);
        return button;
    }

    public void configureTableCellEditorRendererComponent(JTable table,
                                                          Component editorRendererComponent,
                                                          boolean forRenderer,
                                                          Object value,
                                                          boolean isSelected,
                                                          boolean hasFocus,
                                                          int row,
                                                          int column) {
        super.configureTableCellEditorRendererComponent(table, editorRendererComponent, forRenderer, value, isSelected, hasFocus, row, column);
        MJButton button = (MJButton)editorRendererComponent;
        button.setText("");
        button.setIcon(new ImageIcon("" + value));
    }

    public MJButton getButton() {
        return (MJButton)this._editorComponent;
    }

}
