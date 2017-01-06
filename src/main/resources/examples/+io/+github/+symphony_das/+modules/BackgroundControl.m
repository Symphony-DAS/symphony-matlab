classdef BackgroundControl < symphonyui.ui.Module

    properties (Access = private)
        devices
        deviceListeners
        deviceGrid
    end

    methods

        function createUi(obj, figureHandle)
            import appbox.*;

            set(figureHandle, ...
                'Name', 'Background Control', ...
                'Position', screenCenter(290, 100));

            mainLayout = uix.HBox( ...
                'Parent', figureHandle);

            obj.deviceGrid = uiextras.jide.PropertyGrid(mainLayout, ...
                'BorderType', 'none', ...
                'Callback', @obj.onSetBackground);
        end

    end

    methods (Access = protected)

        function willGo(obj)
            obj.devices = obj.configurationService.getOutputDevices();
            obj.populateDeviceGrid();
        end

        function bind(obj)
            bind@symphonyui.ui.Module(obj);

            obj.bindDevices();

            c = obj.configurationService;
            obj.addListener(c, 'InitializedRig', @obj.onServiceInitializedRig);
        end

    end

    methods (Access = private)

        function bindDevices(obj)
            for i = 1:numel(obj.devices)
                obj.deviceListeners{end + 1} = obj.addListener(obj.devices{i}, 'background', 'PostSet', @obj.onDeviceSetBackground);
            end
        end

        function unbindDevices(obj)
            while ~isempty(obj.deviceListeners)
                obj.removeListener(obj.deviceListeners{1});
                obj.deviceListeners(1) = [];
            end
        end

        function populateDeviceGrid(obj)
            try
                fields = device2field(obj.devices);
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.view.showError(x.message);
            end

            set(obj.deviceGrid, 'Properties', fields);
        end

        function updateDeviceGrid(obj)
            try
                fields = device2field(obj.devices);
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.view.showError(x.message);
            end

            obj.deviceGrid.UpdateProperties(fields);
        end

        function onSetBackground(obj, ~, event)
            p = event.Property;
            device = obj.configurationService.getDevice(p.Name);
            background = device.background;
            device.background = symphonyui.core.Measurement(p.Value, device.background.displayUnits);
            try
                device.applyBackground();
            catch x
                device.background = background;
                obj.view.showError(x.message);
                return;
            end
            if ismethod(device, 'availableModes')
                for i = 1:numel(device.availableModes)
                    mode = device.availableModes{i};
                    b = device.getBackgroundForMode(mode);
                    device.setBackgroundForMode(mode, symphonyui.core.Measurement(p.Value, b.displayUnits));
                end
            end
        end

        function onServiceInitializedRig(obj, ~, ~)
            obj.unbindDevices();
            obj.devices = obj.configurationService.getOutputDevices();
            obj.populateDeviceGrid();
            obj.bindDevices();
        end

        function onDeviceSetBackground(obj, ~, ~)
            obj.updateDeviceGrid();
        end

    end

end

function f = device2field(devices)
    f = uiextras.jide.PropertyGridField.empty(0, max(1, numel(devices)));
    for i = 1:numel(devices)
        d = devices{i};
        f(i) = uiextras.jide.PropertyGridField(d.name, d.background.quantity, ...
            'DisplayName', [d.name ' (' d.background.displayUnits ')']);
    end
end
