classdef BackgroundControl < symphonyui.ui.Module
    
    properties (Access = private)
        backgroundGrid
    end
    
    methods
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'Background Control', ...
                'Position', screenCenter(260, 100));
            
            mainLayout = uix.HBox( ...
                'Parent', figureHandle);
            
            obj.backgroundGrid = uiextras.jide.PropertyGrid(mainLayout, ...
                'BorderType', 'none', ...
                'Callback', @obj.onSetBackground);
        end
        
    end
    
    methods (Access = protected)

        function willGo(obj)
            obj.populateBackgroundGrid();
        end
        
        function bind(obj)
            bind@symphonyui.ui.Module(obj);
            
            c = obj.configurationService;
            obj.addListener(c, 'InitializedRig', @obj.onServiceInitializedRig);
        end

    end
    
    methods (Access = private)
        
        function populateBackgroundGrid(obj)
            devices = obj.configurationService.getOutputDevices();
            
            fields = uiextras.jide.PropertyGridField.empty(0, max(1, numel(devices)));
            for i = 1:numel(devices)
                d = devices{i};
                fields(i) = uiextras.jide.PropertyGridField(d.name, d.background.quantity, ...
                    'DisplayName', [d.name ' (' d.background.displayUnits ')']);
            end
            
            set(obj.backgroundGrid, 'Properties', fields);
        end
        
        function onSetBackground(obj, ~, event)
            p = event.Property;
            device = obj.configurationService.getDevice(p.Name);
            background = symphonyui.core.Measurement(p.Value, device.background.displayUnits);
            try
                device.background = background;
                device.applyBackground();
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceInitializedRig(obj, ~, ~)
            obj.populateBackgroundGrid();
        end
        
    end
    
end

