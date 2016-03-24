classdef ProtocolPresetsView < appbox.View
    
    events
        AddPreset
        RemovePreset
    end
    
    properties (Access = private)
        presetsTable
        addButton
        removeButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Protocol Presets', ...
                'Position', screenCenter(230, 300));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Spacing', 1);
            
            obj.presetsTable = appbox.Table( ...
                'Parent', mainLayout, ...
                'ColumnName', {'Presets'}, ...
                'BorderType', 'none', ...
                'Editable', false);
            
            % Presets toolbar.
            presetsToolbarLayout = uix.HBox( ...
                'Parent', mainLayout);
            obj.addButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/add.png'), ...
                'Callback', @(h,d)notify(obj, 'AddPreset'));
            obj.removeButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/remove.png'), ...
                'Callback', @(h,d)notify(obj, 'RemovePreset'));
            uix.Empty('Parent', presetsToolbarLayout);
            set(presetsToolbarLayout, 'Widths', [22 22 -1]);
            
            set(mainLayout, 'Heights', [-1 22]);
        end
        
        function show(obj)
            show@appbox.View(obj);
            drawnow();
            set(obj.presetsTable, 'ColumnHeaderVisible', false);
        end
        
    end
    
end

