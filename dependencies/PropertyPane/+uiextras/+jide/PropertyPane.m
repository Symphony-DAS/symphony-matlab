classdef PropertyPane < matlab.mixin.SetGet %#ok<*MCSUP>
    
    properties
        Parent
        Enable
        Properties
        Selection
        Callback
    end
    
    properties (Access = private)
        Table
        Pane
        Model
        Fields
        Container
    end
    
    methods
        
        function obj = PropertyPane(varargin)            
            import com.jidesoft.grid.*;
            
            jpath = fullfile(fileparts(mfilename('fullpath')), 'UIExtrasPropertyPane.jar');
            if ~any(ismember(javaclasspath, jpath))
                javaaddpath(jpath);
            end
            
            com.mathworks.mwswing.MJUtilities.initJIDE;
            CellEditorManager.registerEditor(javaclass('cellstr',1), StringArrayCellEditor);
            CellEditorManager.registerEditor(javaclass('char',1), MultilineStringCellEditor, MultilineStringCellEditor.CONTEXT);
            CellRendererManager.registerRenderer(javaclass('char',1), MultilineStringCellRenderer, MultilineStringCellEditor.CONTEXT);
            
            obj.Table = handle(objectEDT('com.jidesoft.grid.PropertyTable'), 'CallbackProperties');
            set(obj.Table, 'KeyPressedCallback', @(h,d)obj.OnKeyPress(h, d));
            
            obj.Pane = objectEDT('com.jidesoft.grid.PropertyPane', obj.Table);
            obj.Pane.setShowToolBar(false);
            obj.Pane.setShowDescription(false);
            
            style = CellStyle();
            style.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            obj.Model = handle(UIExtrasPropertyPane.CellStylePropertyTableModel(), 'CallbackProperties');
            obj.Model.setCategoryOrder(1);
            obj.Model.setCellStyle(style);
            set(obj.Model, 'PropertyChangeCallback', @(h,d)obj.OnPropertyChangeCallback(h, d));
            obj.Table.setModel(obj.Model);
            
            obj.Fields = JidePropertyGridField.empty(0, 1);
            
            obj.set(varargin{:});
        end
        
        function Close(obj)
            set(obj.Table, 'KeyPressedCallback', []);
            set(obj.Model, 'PropertyChangeCallback', []);
        end
        
        function OnKeyPress(obj, ~, ~)
            disp('key!');
        end
        
        function set.Parent(obj, parent)
            position = getpixelposition(parent);
            [~, obj.Container] = javacomponent(obj.Pane, [0 0 position(3) position(4)], parent);
            set(obj.Container, 'Units', 'normalized');
        end
        
        function tf = get.Enable(obj)
            tf = obj.Table.getEnabled();
        end

        function set.Enable(obj, tf)
            obj.Table.setEnabled(tf);
        end
        
        function p = get.Properties(obj)
            p = obj.Fields.GetProperties();
        end
        
        function set.Properties(obj, properties)      
            validateattributes(properties, {'PropertyGridField'}, {'vector'});
            
            obj.Fields = JidePropertyGridField.empty(0,1);
            for i = 1:numel(properties)
                obj.Fields(i) = JidePropertyGridField(properties(i));
            end
            list = obj.Fields.GetTableModel();
            
            obj.Model.setOriginalProperties(list);
            
            if properties.HasCategory();
                obj.Model.setOrder(0);
            else
                obj.Model.setOrder(2);
            end
            obj.Model.refresh();
            obj.Model.expandAll();
            
            obj.Pane.setShowDescription(properties.HasDescription());
        end
        
        function set.Selection(obj, index)
            prop = obj.Fields(index).GetTableModel().get(0);
            obj.Table.setSelectedProperty(prop);
        end
        
        function i = get.Selection(obj)
            prop = obj.Table.getSelectedProperty();
            list = obj.Fields.GetTableModel();
            i = list.indexOf(prop) + 1;
        end
        
    end
    
    methods (Access = private)
        
        function OnPropertyChangeCallback(obj, ~, event)
            if ~isempty(obj.Callback)
                name = get(event, 'PropertyName');
                field = obj.Fields.FindByName(name);
                value = field.Value;
                
                didChange = false;
                if field.CanAccept(value)
                    try
                        field.PropertyData.Value = value;
                        didChange = true;
                    catch x
                        field.Value = field.PropertyData.Value;
                        obj.Table.repaint();
                        rethrow(x);
                    end
                else
                    field.Value = field.PropertyData.Value;
                    obj.Table.repaint();
                end
                
                if didChange
                    obj.Callback(obj, uiextras.jide.PropertyEventData(field.PropertyData));
                end
            end
        end
        
    end
    
end

    