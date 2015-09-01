% Mimics uicontrol 'popupmenu' with the addition of being able to define a values array.

classdef MappedPopupMenu < symphonyui.ui.util.UIControl %#ok<*MCSUP>
    
    properties
        Values
    end
    
    methods
        
        function obj = MappedPopupMenu(varargin)
            obj@symphonyui.ui.util.UIControl( ...
                varargin{:}, ...
                'Style', 'popupmenu');
        end   
        
        function setString(obj, string)
            set(obj.Control, 'String', string);
            values = cell(1, numel(string));
            for i = 1:numel(string)
                values{i} = i;
            end
            obj.Values = values;
        end
        
        function set.Values(obj, values)
            if numel(values) ~= numel(obj.String)
                error('String and Values must have the same number of elements');
            end
            obj.Values = values;
            if get(obj.Control, 'Value') > numel(values)
                set(obj.Control, 'Value', numel(values));
            end
        end
        
        function v = getValue(obj)
            index = get(obj.Control, 'Value');
            v = obj.Values{index};
        end
        
        function setValue(obj, value)
            index = find(cellfun(@(v)isequal(v, value), obj.Values));
            set(obj.Control, 'Value', index)
        end
        
    end
    
end

