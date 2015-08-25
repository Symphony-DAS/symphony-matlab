classdef Calibrator < symphonyui.ui.Module
    
    properties (Access = private)
        deviceListBox
        voltageField
        readingField
        spotSizeField
        calibrateButton
    end
    
    methods
        
        function createUi(obj, figureHandle)
            import symphonyui.ui.util.*;
            
            set(figureHandle, ...
                'Name', 'Calibrator', ...
                'Position', screenCenter(300, 160));
            
            mainLayout = uix.HBox( ...
                'Parent', figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);
            
            masterLayout = uix.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.deviceListBox = uicontrol( ...
                'Parent', masterLayout, ...
                'Style', 'listbox', ...
                'Callback', @obj.onSelectedDevice);
            
            detailLayout = uix.VBox( ...
                'Parent', mainLayout);
            
            inputsLayout = uix.Grid( ...
                'Parent', detailLayout, ...
                'Spacing', 7);
            
            Label( ...
                'Parent', inputsLayout, ...
                'String', 'Voltage:');
            Label( ...
                'Parent', inputsLayout, ...
                'String', 'Reading:');
            Label( ...
                'Parent', inputsLayout, ...
                'String', 'Spot size:');
            obj.voltageField = uicontrol( ...
                'Parent', inputsLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.readingField = uicontrol( ...
                'Parent', inputsLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.spotSizeField = uicontrol( ...
                'Parent', inputsLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            
            set(inputsLayout, ...
                'Widths', [50 -1], ...
                'Heights', [25 25 25]);
            
            % Add/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', detailLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.calibrateButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Calibrate', ...
                'Callback', @obj.onCalibrate);
            set(controlsLayout, 'Widths', [-1 75]);
            
            set(detailLayout, 'Heights', [-1 25]);
            
            set(mainLayout, 'Widths', [-1 -1.5]);
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.populateDeviceList();
        end
        
    end
    
    methods (Access = private)
        
        function populateDeviceList(obj)
            if ~obj.configurationService.hasRig()
                set(obj.deviceListBox, 'String', {});
                return;
            end
            devices = obj.configurationService.getDevices('LED');
            names = cellfun(@(d)d.name, devices, 'UniformOutput', false);
            set(obj.deviceListBox, 'String', names);
        end
        
        function onSelectedDevice(obj, ~, ~)
            disp(obj.getSelectedDevice());
        end
        
        function d = getSelectedDevice(obj)
            devices = get(obj.deviceListBox, 'String');
            if isempty(devices)
                d = [];
                return;
            end
            index = get(obj.deviceListBox, 'Value');
            d = devices{index};
        end
        
        function onCalibrate(obj, ~, ~)
            obj.selectNextDevice();
            disp(obj.getSelectedDevice());
        end
        
        function selectNextDevice(obj)
            devices = get(obj.deviceListBox, 'String');
            if isempty(devices)
                return;
            end
            index = get(obj.deviceListBox, 'Value');
            next = mod(index, numel(devices)) + 1;
            set(obj.deviceListBox, 'Value', next);
        end
        
    end
    
end

