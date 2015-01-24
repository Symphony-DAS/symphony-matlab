classdef AboutSymphonyView < symphonyui.View
    
    events
        Ok
    end
    
    properties (Access = private)
        aboutText
        okButton
    end
    
    methods
        
        function obj = AboutSymphonyView(parent)
            obj = obj@symphonyui.View(parent);
        end
        
        function createUI(obj)
            import symphonyui.utilities.*;
            
            set(obj.figureHandle, 'Name', 'About Symphony');
            set(obj.figureHandle, 'Position', screenCenter(236, 104));
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            obj.aboutText = uicontrol( ...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Symphony Data Acquisition System', ...
                'HorizontalAlignment', 'center');
            
            % Ok control.
            controlsLayout = uiextras.HBox('Parent', mainLayout);
            uiextras.Empty('Parent', controlsLayout');
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            uiextras.Empty('Parent', controlsLayout');
            set(controlsLayout, 'Sizes', [-1 75 -1]);
            
            set(mainLayout, 'Sizes', [-1 25]);
        end
        
        function setAboutText(obj, t)
            set(obj.aboutText, 'String', t);
        end
        
    end
    
end

