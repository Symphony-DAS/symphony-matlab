package UIExtrasTable;

import com.jidesoft.converter.ConverterContext;
import com.jidesoft.grid.ButtonTableCellEditorRenderer;
import com.mathworks.mwswing.MJButton;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Vector;

public class MButtonTableCellEditorRenderer extends ButtonTableCellEditorRenderer {

    private int editingRow;
    private int editingColumn;

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
                                                          final int row,
                                                          final int column) {
        super.configureTableCellEditorRendererComponent(table, editorRendererComponent, forRenderer, "", isSelected, hasFocus, row, column);
        MJButton button = (MJButton)editorRendererComponent;
        try {
            Object[] values = (Object[])value;
            button.setIcon(new ImageIcon((String)values[0]));
            button.setToolTipText((String)values[1]);
            button.setEnabled((Boolean)values[2]);
        } catch(Exception ignored) {
            // Not sure why this is sometimes passed in as junk
            button.setIcon(null);
            button.setToolTipText("");
            button.setEnabled(false);
        }
        button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                // HACK: Need to use an existing event so we don't need to add this class to the MATLAB java static classpath.
                editingRow = row;
                editingColumn = column;
                synchronized (this) {
                    fireEditingCanceled();
                }
            }
        });
    }

    public int getEditingRow() {
        return editingRow;
    }

    public int getEditingColumn() {
        return editingColumn;
    }

//    public synchronized void addCellActionListener(CellActionListener listener) {
//        data.addElement(listener);
//    }
//
//    public synchronized void removeCellActionListener(CellActionListener listener) {
//        data.removeElement(listener);
//    }
//
//    protected void fireCellActionPerformed(CellActionEvent event) {
//        Vector dataCopy;
//        synchronized (this) {
//            dataCopy = (Vector) data.clone();
//        }
//        for (int i = 0; i < dataCopy.size(); i++) {
//            ((CellActionListener)dataCopy.elementAt(i)).cellActionPerformed(event);
//        }
//    }
//
//    public interface CellActionListener extends EventListener {
//        void cellActionPerformed(CellActionEvent e);
//    }
//
//    public class CellActionEvent extends EventObject {
//        private static final long serialVersionUID = 1L;
//        private int id;
//        private String command;
//        private int row;
//        private int column;
//
//        public CellActionEvent(Object source, int id, String command, int row, int column) {
//            super(source);
//            this.id = id;
//            this.command = command;
//            this.row = row;
//            this.column = column;
//        }
//
//        public int getRow() {
//            return row;
//        }
//
//        public int getColumn() {
//            return column;
//        }
//
//    }

}