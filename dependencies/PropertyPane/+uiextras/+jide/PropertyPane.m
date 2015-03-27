classdef PropertyPane < matlab.mixin.SetGet
    
    properties (Dependent)
        Parent
        Enable
        Properties
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
            set(obj.Table, 'KeyPressedCallback', @obj.OnKeyPress);
            
            obj.Pane = objectEDT('com.jidesoft.grid.PropertyPane', obj.Table);
            obj.Pane.setShowToolBar(false);
            obj.Pane.setShowDescription(false);
            
            style = CellStyle();
            style.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            obj.Model = handle(UIExtrasPropertyPane.CellStylePropertyTableModel(), 'CallbackProperties');
            obj.Model.setCellStyle(style);
            obj.Table.setModel(obj.Model);
            
            obj.Fields = JidePropertyGridField.empty(0, 1);
            
            obj.set(varargin{:});
        end
        
        function Close(obj)
            set(obj.Table, 'KeyPressedCallback', []);
            set(obj.Model, 'PropertyChangeCallback', []);
        end
        
        function onKeyPress(obj, ~, ~)
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
            
            hasCategory = properties.HasCategory();
            hasDescription = properties.HasDescription();
            
            if hasCategory
                obj.Model.setOrder(0);
            else
                obj.Model.setOrder(2);
            end
            obj.Model.refresh();
            obj.Model.expandAll();
            
            obj.Pane.setShowToolBar(hasCategory);
            obj.Pane.setShowDescription(hasDescription);
        end
        
        function c = get.Callback(obj)
            c = get(obj.Model, 'PropertyChangeCallback');
        end
        
        function set.Callback(obj, c)
            set(obj.Model, 'PropertyChangeCallback', c);
        end
        
    end
    
end

    