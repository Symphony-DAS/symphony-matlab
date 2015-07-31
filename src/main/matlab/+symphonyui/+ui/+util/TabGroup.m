% Mimics uitabgroup with the addition of being able to enable/disable.

classdef TabGroup < matlab.mixin.SetGet %#ok<*MCSUP>
    
    properties
        Parent
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
        
        function addTab(obj, tab)
            set(tab, 'Parent', obj.Control);
        end
        
        function insertTab(obj, tab, index)
            if index < 1 || index > numel(get(obj.Control, 'Children')) + 1
                error('Index out of bounds');
            end            
            set(tab, 'Parent', obj.Control);
            c = get(obj.Control, 'Children');
            set(obj.Control, 'Children', [c(1:index-1); tab; c(index:end-1);]);
        end
        
        function removeTab(obj, tab) %#ok<INUSL>
            set(tab, 'Parent', []);
        end
        
        function p = get.Parent(obj)
            p = get(obj.Control, 'Parent');
        end
        
        function set.Parent(obj, p)
            set(obj.Control, 'Parent', p);
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

