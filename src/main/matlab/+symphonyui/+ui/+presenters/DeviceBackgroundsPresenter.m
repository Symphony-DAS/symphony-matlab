classdef DeviceBackgroundsPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        log
        configurationService
    end
    
    methods
        
        function obj = DeviceBackgroundsPresenter(configurationService, view)
            if nargin < 2
                view = symphonyui.ui.views.DeviceBackgroundsView();
            end
            obj = obj@symphonyui.ui.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.configurationService = configurationService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj, ~, ~)
            obj.populateDeviceBackgrounds();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Apply', @obj.onViewSelectedApply);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end
    
    methods (Access = private)
        
        function populateDeviceBackgrounds(obj)
            devices = obj.configurationService.getDevices();
            
            try
                fields = uiextras.jide.PropertyGridField.empty(0, max(numel(devices), 1));
                for i = 1:numel(devices)
                    d = devices{i};
                    fields(i) = uiextras.jide.PropertyGridField(d.name, d.background.quantity , ...
                        'DisplayName', [d.name ' (' d.background.displayUnits ')']);
                end
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            
            obj.view.setDeviceBackgrounds(fields);
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedApply();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedApply(obj, ~, ~)
            obj.view.stopEditingDeviceBackgrounds();
            obj.view.update();
            
            backgrounds = obj.view.getDeviceBackgrounds();
            try
                for i = 1:numel(backgrounds)
                    d = obj.configurationService.getDevice(backgrounds(i).Name);
                    d.background = symphonyui.core.Measurement(backgrounds(i).Value, d.background.displayUnits);
                    d.applyBackground();
                end
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.result = true;
            obj.close();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.close();
        end
        
    end
    
end

