% Mimics uicontrol 'edit' with the addition of being able to define an autocompletion list.

classdef AutoCompletionTextField < symphonyui.ui.util.UIControl %#ok<*MCSUP>
    
    properties
        AutoCompletion
    end
    
    methods
        
        function obj = AutoCompletionTextField(varargin)
            obj@symphonyui.ui.util.UIControl( ...
                varargin{:}, ...
                'Style', 'edit');
        end
        
        function s = getString(obj)
            s = char(obj.JControl.getText());
        end
        
        function set.AutoCompletion(obj, list)
            auto = com.jidesoft.swing.AutoCompletion(obj.JControl, java.util.Arrays.asList(list));
            auto.setStrict(false);
            obj.AutoCompletion = list;
        end
        
    end
    
end

