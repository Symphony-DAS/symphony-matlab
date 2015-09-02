classdef HoldingLevelsPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        configurationService
    end
    
    methods
        
        function obj = HoldingLevelsPresenter(configurationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.HoldingLevelsView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.view.setWindowStyle('modal');
            
            obj.configurationService = configurationService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj, ~, ~)
            obj.populateHoldingLevels();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Apply', @obj.onViewSelectedApply);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end
    
    methods (Access = private)
        
        function populateHoldingLevels(obj)
            devices = obj.configurationService.getDevices();
            
            try
                fields = uiextras.jide.PropertyGridField.empty(0, max(numel(devices), 1));
                for i = 1:numel(devices)
                    d = devices{i};
                    fields(i) = uiextras.jide.PropertyGridField(d.name, d.background.quantity);
                end
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            
            obj.view.setHoldingLevels(fields);
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
            obj.view.stopEditingHoldingLevels();
            obj.view.update();
            
            levels = obj.view.getHoldingLevels();
            try
                for i = 1:numel(levels)
                    d = obj.configurationService.getDevice(levels(i).Name);
                    d.background = symphonyui.core.Measurement(levels(i).Value, d.background.displayUnits);
                    d.applyBackground();
                end
            catch x
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

