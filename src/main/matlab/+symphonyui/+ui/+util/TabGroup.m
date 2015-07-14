% Mimics uitabgroup with the addition of being able to enable/disable.

classdef TabGroup < matlab.mixin.SetGet %#ok<*MCSUP>
    
    properties
        Enable
        SelectedTab
    end
    
    properties (Access = private)
        Control
        JControl
    end
    
    methods
        
        function obj = TabGroup(varargin)
            obj.Control = uitabgroup(varargin{:});
        end
        
        function t = addTab(obj, varargin)
            t = uitab(varargin{:}, 'Parent', obj.Control);
        end
        
        function e = get.Enable(obj)
            tf = obj.JControl.getEnabled();
            e = symphonyui.ui.util.onOff(tf);
        end
        
        function set.Enable(obj, e)
            if strcmpi(e, 'on')
                obj.JControl.setEnabled(true);
            else
                obj.JControl.setEnabled(false);
            end
        end
        
        function t = get.SelectedTab(obj)
            t = get(obj.Control, 'SelectedTab');
        end
        
        function set.SelectedTab(obj, t)
            set(obj.Control, 'SelectedTab', t);
        end
        
        function c = get.JControl(obj)
            if isempty(obj.JControl)
                obj.JControl = findjobj(obj.Control, 'class', 'JTabbedPane');
            end
            c = obj.JControl;
        end
        
    end
    
end

