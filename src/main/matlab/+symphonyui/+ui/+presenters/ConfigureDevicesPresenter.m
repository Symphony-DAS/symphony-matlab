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
            obj.updateStateOfControls();
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'SelectedDevice', @obj.onViewSelectedDevice);
            obj.addListener(v, 'SetConfigurationSetting', @obj.onViewSetConfigurationSetting);
            obj.addListener(v, 'AddConfigurationSetting', @obj.onViewSelectedAddConfigurationSetting);
            obj.addListener(v, 'RemoveConfigurationSetting', @obj.onViewSelectedRemoveConfigurationSetting);
        end
        
    end

    methods (Access = private)
        
        function populateDeviceList(obj)
            devices = obj.configurationService.getDevices();
            names = cellfun(@(d)d.name, devices, 'UniformOutput', false);
            obj.view.setDeviceList(names, devices);
            
            device = obj.view.getSelectedDevice();
            if ~isempty(device)
                obj.populateDetailsWithDevice(device);
            end
        end
        
        function onViewSelectedDevice(obj, ~, ~)
            obj.view.update();
            obj.populateDetailsWithDevice(obj.view.getSelectedDevice());
        end
        
        function populateDetailsWithDevice(obj, device)            
            obj.view.setName(device.name);
            obj.view.setManufacturer(device.manufacturer);
            obj.view.setInputStreams(strjoin(cellfun(@(s)s.name, device.inputStreams, 'UniformOutput', false), ', '));
            obj.view.setOutputStreams(strjoin(cellfun(@(s)s.name, device.outputStreams, 'UniformOutput', false), ', '));
            
            obj.populateConfigurationWithDevice(device);
        end
        
        function populateConfigurationWithDevice(obj, device)
            try
                fields = symphonyui.ui.util.desc2field(device.getConfigurationDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.setConfiguration(fields);
        end
        
        function updateConfigurationWithDevice(obj, device)
            try
                fields = symphonyui.ui.util.desc2field(device.getConfigurationDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.updateConfiguration(fields);
        end
        
        function onViewSetConfigurationSetting(obj, ~, event)
            p = event.data.Property;
            try
                obj.view.getSelectedDevice().addConfigurationSetting(p.Name, p.Value);
            catch x
                obj.view.showError(x.message);
                return;
            end
            obj.updateConfigurationWithDevice(obj.view.getSelectedDevice());
        end
        
        function onViewSelectedAddConfigurationSetting(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddConfigurationSettingPresenter(obj.view.getSelectedDevice());
            presenter.goWaitStop();

            if ~isempty(presenter.result)
                obj.populateConfigurationWithDevice(obj.view.getSelectedDevice());
            end
        end
        
        function onViewSelectedRemoveConfigurationSetting(obj, ~, ~)            
            key = obj.view.getSelectedConfigurationSetting();
            if isempty(key)
                return;
            end           
            
            try
                tf = obj.view.getSelectedDevice().removeConfigurationSetting(key);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            if tf
                obj.populateConfigurationWithDevice(obj.view.getSelectedDevice());
            end
        end
        
        function updateStateOfControls(obj)
            hasDevice = ~isempty(obj.configurationService.getDevices());
            
            obj.view.enableDeviceList(hasDevice);
            obj.view.enableAddConfigurationSetting(hasDevice);
            obj.view.enableRemoveConfigurationSetting(hasDevice);
        end

    end

end
