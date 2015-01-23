classdef SetRigView < SymphonyUI.View
    
    events
        Ok
        Cancel
    end
    
    properties (Access = private)
        rigDropDown
        okButton
        cancelButton
    end
    
    methods
        
        function obj = SetRigView(parent)
            obj = obj@SymphonyUI.View(parent);
        end
        
        function createUI(obj)
            import SymphonyUI.Utilities.*;
            import SymphonyUI.Utilities.UI.*;
            
            set(obj.figureHandle, 'Name', 'Set Rig');
            set(obj.figureHandle, 'Position', screenCenter(236, 79));
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            rigLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.rigDropDown = createLabeledDropDownMenu(rigLayout, 'Rig:', [25 -1]);
            
            % Ok/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);
            
            set(mainLayout, 'Sizes', [-1 25]);
            
            % Set ok button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end
        
        function r = getRig(obj)
            r = SymphonyUI.Utilities.UI.getSelectedValue(obj.rigDropDown);
        end
        
        function setRigList(obj, r)
            SymphonyUI.Utilities.UI.setStringList(obj.rigDropDown, r);
        end
        
        function enableOk(obj, tf)
            set(obj.okButton, 'Enable', SymphonyUI.Utilities.onOff(tf));
        end
        
    end
    
end

