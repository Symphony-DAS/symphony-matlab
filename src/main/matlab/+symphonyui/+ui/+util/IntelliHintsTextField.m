% Mimics uicontrol 'edit' with the addition of being able to define an autocompletion list.

classdef IntelliHintsTextField < symphonyui.ui.util.UIControl %#ok<*MCSUP>
    
    properties
        CompletionList
    end
    
    properties (Access = private)
        IntelliHints
    end
    
    methods
        
        function obj = IntelliHintsTextField(varargin)
            obj@symphonyui.ui.util.UIControl( ...
                varargin{:}, ...
                'Style', 'edit');
        end
        
        function set.CompletionList(obj, list)
            obj.IntelliHints = com.jidesoft.hints.ListDataIntelliHints(obj.JControl, java.util.Arrays.asList(list));
        end
        
        function showHints(obj)
            obj.IntelliHints.showHints();
        end
        
        function s = getString(obj)
            s = char(obj.JControl.getText());
            %s = get(obj.Control, 'String');
        end
        
    end
    
end

