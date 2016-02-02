classdef ConfigureDevicesPresenter < appbox.Presenter

    properties (Access = private)
        log
        configurationService
        detailedDeviceSet
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
            obj.detailedDeviceSet = symphonyui.core.collections.DeviceSet();
        end

    end

    methods (Access = protected)
        
        function onGoing(obj, ~, ~)
            obj.populateDeviceList();
            obj.updateStateOfControls();
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'SelectedDevices', @obj.onViewSelectedDevices);
            obj.addListener(v, 'SetBackground', @obj.onViewSetBackground);
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
            
            devices = obj.view.getSelectedDevices();
            obj.populateDetailsWithDevices(devices);
        end
        
        function onViewSelectedDevices(obj, ~, ~)
            obj.view.stopEditingConfiguration();
            obj.view.update();
            obj.populateDetailsWithDevices(obj.view.getSelectedDevices());
        end
        
        function populateDetailsWithDevices(obj, devices)
            deviceSet = symphonyui.core.collections.DeviceSet(devices);
            
            obj.view.setName(deviceSet.name);
            obj.view.setManufacturer(deviceSet.manufacturer);
            obj.view.setInputStreams(strjoin(cellfun(@(s)s.name, deviceSet.inputStreams, 'UniformOutput', false), ', '));
            obj.view.setOutputStreams(strjoin(cellfun(@(s)s.name, deviceSet.outputStreams, 'UniformOutput', false), ', '));
            
            background = deviceSet.background;
            if isempty(background)
                obj.view.setBackground('');
            else
                obj.view.setBackground(num2str(background.quantity));
            end
            
            backgroundUnits = deviceSet.getBackgroundDisplayUnits();            
            obj.view.enableBackground(~isempty(backgroundUnits));
            obj.view.setBackgroundUnits(backgroundUnits);
            
            obj.populateConfigurationWithDeviceSet(deviceSet);
            obj.detailedDeviceSet = deviceSet;
        end
        
        function populateConfigurationWithDeviceSet(obj, deviceSet)
            try
                fields = symphonyui.ui.util.desc2field(deviceSet.getConfigurationSettingDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.setConfiguration(fields);
        end
        
        function updateConfigurationWithDeviceSet(obj, deviceSet)
            try
                fields = symphonyui.ui.util.desc2field(deviceSet.getConfigurationSettingDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.updateConfiguration(fields);
        end
        
        function onViewSetBackground(obj, ~, ~)
            deviceSet = obj.detailedDeviceSet;
            
            try
                deviceSet.background = symphonyui.core.Measurement(str2double(obj.view.getBackground()), obj.view.getBackgroundUnits());
                deviceSet.applyBackground();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSetConfigurationSetting(obj, ~, event)
            p = event.data.Property;
            try
                obj.detailedDeviceSet.setConfigurationSetting(p.Name, p.Value);
            catch x
                obj.view.showError(x.message);
                return;
            end
            obj.updateConfigurationWithDeviceSet(obj.detailedDeviceSet);
        end
        
        function onViewSelectedAddConfigurationSetting(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddConfigurationSettingPresenter(obj.detailedDeviceSet);
            presenter.goWaitStop();

            if ~isempty(presenter.result)
                obj.populateConfigurationWithDeviceSet(obj.detailedDeviceSet);
            end
        end
        
        function onViewSelectedRemoveConfigurationSetting(obj, ~, ~)            
            key = obj.view.getSelectedConfigurationSetting();
            if isempty(key)
                return;
            end           
            try
                tf = obj.detailedDeviceSet.removeConfigurationSetting(key);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            if tf
                obj.populateConfigurationWithDeviceSet(obj.detailedDeviceSet);
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
