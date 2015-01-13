classdef AboutSymphonyView < SymphonyUI.View
    
    events
        Ok
    end
    
    properties (Access = private)
        aboutText
        okButton
    end
    
    methods
        
        function obj = AboutSymphonyView(parent)
            obj = obj@SymphonyUI.View(parent);
        end
        
        function createUI(obj)
            import SymphonyUI.Utilities.*;
            
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
            
            layout = uiextras.HBox('Parent', mainLayout);
            uiextras.Empty('Parent', layout');
            obj.okButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            uiextras.Empty('Parent', layout');
            set(layout, 'Sizes', [-1 75 -1]);
            
            set(mainLayout, 'Sizes', [-1 25]);
        end
        
        function setAboutText(obj, t)
            set(obj.aboutText, 'String', t);
        end
        
    end
    
end

