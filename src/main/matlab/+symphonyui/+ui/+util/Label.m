% Mimics uicontrol 'text' with the addition of being vertically centered.

classdef Label < matlab.mixin.SetGet %#ok<*MCSUP>
    
    properties
        String
        BackgroundColor
        HorizontalAlignment
    end
    
    properties (Access = private)
        Control
        JControl
    end
    
    methods
        
        function obj = Label(varargin)
            p = inputParser();
            p.KeepUnmatched = true;
            p.addOptional('Parent', get(groot, 'CurrentFigure'));
            p.parse(varargin{:});
            [obj.JControl, obj.Control] = javacomponent(javax.swing.JLabel(), [], p.Results.Parent);
            obj.set(p.Unmatched);
        end
        
        function s = get.String(obj)
            s = char(obj.JControl.getText());
        end
        
        function set.String(obj, s)
            obj.JControl.setText(s);
        end
        
        function c = get.BackgroundColor(obj)
            color = obj.JControl.getBackground;
            c = [color.getRed(), color.getGreen(), color.getBlue()];
        end
        
        function set.BackgroundColor(obj, c)
            switch lower(c)
                case {'w', 'white'}
                    c = [1 1 1];
                otherwise
                    error('Not supported');
            end
            obj.JControl.setBackground(java.awt.Color(c(1), c(2), c(3)));
        end
        
        function a = get.HorizontalAlignment(obj)
            a = obj.JControl.getHorizontalAlignment();
            switch a
                case javax.swing.SwingConstants.LEFT
                    a = 'left';
                case javax.swing.SwingConstants.CENTER
                    a = 'center';
                case javax.swing.SwingConstants.RIGHT
                    a = 'right';
            end
        end
        
        function set.HorizontalAlignment(obj, a)
            switch lower(a)
                case 'left'
                    a = javax.swing.SwingConstants.LEFT;
                case 'center'
                    a = javax.swing.SwingConstants.CENTER;
                case 'right'
                    a = javax.swing.SwingConstants.RIGHT;
                otherwise
                    error('Not supported');
            end
            obj.JControl.setHorizontalAlignment(a);
        end
        
    end
    
end

