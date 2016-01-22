classdef ConfigureDevicesPresenter < appbox.Presenter

    properties (Access = private)
        log
        configurationService
    end

    methods

        function obj = ConfigureDevicesPresenter(configurationService, view)
            if nargin < 2
                view = symphonyui.ui.views.ConfigureDevicesView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.configurationService = configurationService;
        end

    end

    methods (Access = protected)
        
        function onGoing(obj, ~, ~)
            obj.populateDeviceList();
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'SelectedDevice', @obj.onViewSelectedDevice);
        end
        
    end

    methods (Access = private)
        
        function populateDeviceList(obj)
            devices = obj.configurationService.getDevices();
            names = cellfun(@(d)d.name, devices, 'UniformOutput', false);
            obj.view.setDeviceList(names, devices);
            obj.populateDetailsWithDevice(obj.view.getSelectedDevice());
        end
        
        function onViewSelectedDevice(obj, ~, ~)
            obj.view.update();
            obj.populateDetailsWithDevice(obj.view.getSelectedDevice());
        end
        
        function populateDetailsWithDevice(obj, device)
            if isempty(device)
                obj.view.setDeviceName('');
                obj.view.setDeviceManufacturer('');
                obj.view.setDeviceBackground('');
                return;
            end
            obj.view.setDeviceName(device.name);
            obj.view.setDeviceManufacturer(device.manufacturer);
            obj.view.enableDeviceBackground(~isempty(device.outputStreams));
            obj.view.setDeviceBackground(num2str(device.background.quantity));
        end

    end

end
