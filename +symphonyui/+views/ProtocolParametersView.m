classdef ProtocolParametersView < symphonyui.View
    
    events
        SelectedPreset
        Apply
        Revert
    end
    
    properties (Access = private)
        parametersTable
        presetDropDown
        applyButton
        revertButton
    end
    
    methods
        
        function obj = ProtocolParametersView(parent)
            obj = obj@symphonyui.View(parent);
        end
        
        function createUI(obj)
            import symphonyui.utilities.*;
            import symphonyui.utilities.ui.*;
            
            set(obj.figureHandle, 'Name', 'Protocol Parameters');
            set(obj.figureHandle, 'Position', screenCenter(300, 326));
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            parametersLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.parametersTable = uitable( ...
                'Parent', parametersLayout, ...
                'ColumnName', {'Parameter', 'Value'}, ...
                'ColumnWidth', {130, 130}, ...
                'RowName', [], ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            
            % Apply/Revert controls.
            layout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', layout);
            obj.applyButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', 'Apply', ...
                'Callback', @(h,d)notify(obj, 'Apply'));
            obj.revertButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', 'Revert', ...
                'Callback', @(h,d)notify(obj, 'Revert'));
            set(layout, 'Sizes', [-1 75 75]);
            
            set(mainLayout, 'Sizes', [-1 25]);
            
            % Set apply button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.applyButton);
            end
        end
        
        function addParameter(obj, name, value)
            data = get(obj.parametersTable, 'Data');
            data = [data; {name, value}];
            set(obj.parametersTable, 'Data', data);
        end
        
        function clearParameters(obj)
            set(obj.parametersTable, 'Data', []);
        end
        
        function p = getPreset(obj)
            p = symphonyui.utilities.getSelectedUIValue(obj.presetDropDown);
        end
        
    end
    
end

