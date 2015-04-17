classdef RigView < symphonyui.ui.View

    events
        
    end
    
    properties (Access = private)
        daqControllerField
        devicesTable
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Rig');
            set(obj.figureHandle, 'Position', screenCenter(450, 250));

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
                'Buttons', 'off');
            obj.devicesTable.getTableScrollPane.getRowHeader.setVisible(0);
            
            set(rigLayout, 'Sizes', [25 -1]);
        end
        
        function setDaqController(obj, c)
            set(obj.daqControllerField, 'String', c);
        end
        
        function addDevice(obj, name, input, output, background)
            jtable = obj.devicesTable.getTable();
            jtable.getModel().addRow({name, input, output, background});
        end

    end

end
