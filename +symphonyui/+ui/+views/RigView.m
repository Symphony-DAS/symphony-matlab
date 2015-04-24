classdef RigView < symphonyui.ui.View
    
    properties (Access = private)
        daqControllerField
        devicesTable
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Rig');
            set(obj.figureHandle, 'Position', screenCenter(400, 220));
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            rigLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            rigLabelSize = 100;
            
            obj.daqControllerField = createLabeledTextField(rigLayout, 'DAQ Controller:', rigLabelSize, 'Enable', 'off');
            
            obj.devicesTable = createTable( ...
                'Parent', rigLayout, ...
                'Container', rigLayout, ...
                'Headers', {'Name', 'Input', 'Output', 'Background'}, ...
                'Editable', false, ...
                'RowSelectionAllowed', false, ...
                'ColumnSelectionAllowed', false, ...
                'Buttons', 'off');
            obj.devicesTable.getTableScrollPane.getRowHeader.setVisible(0);
            
            set(rigLayout, 'Sizes', [25 -1]);
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
