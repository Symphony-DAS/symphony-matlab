classdef RigView < symphonyui.ui.View
    
    properties (Access = private)
        daqControllerField
        devicesTable
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, ...
                'Name', 'Rig', ...
                'Position', screenCenter(400, 220));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            daqLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            createLabel(daqLayout, 'DAQ Controller:');
            obj.daqControllerField = createTextField(daqLayout);
            set(daqLayout, 'Widths', [70 -1]);
            
            obj.devicesTable = createTable( ...
                'Parent', mainLayout, ...
                'Container', rigLayout, ...
                'Headers', {'Name', 'Input', 'Output', 'Background'}, ...
                'Editable', false, ...
                'RowSelectionAllowed', false, ...
                'ColumnSelectionAllowed', false, ...
                'Buttons', 'off');
            obj.devicesTable.getTableScrollPane.getRowHeader.setVisible(0);
            
            set(mainLayout, 'Heights', [25 -1]);
        end
        
        function setDaqController(obj, c)
            set(obj.daqControllerField, 'String', c);
        end
        
        function addDevice(obj, name, input, output)
            symphonyui.ui.util.addRowValue(obj.devicesTable, {name, input, output});
        end
        
        function setDeviceBackground(obj, name, background, units)
            i = symphonyui.ui.util.getRowIndex(obj.devicesTable, name);
            jtable = obj.devicesTable.getTable();
            jmodel = jtable.getModel();
            jmodel.setValueAt([num2str(background) ' ' units], i, 3);
        end

    end

end
