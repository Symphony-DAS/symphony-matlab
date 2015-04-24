classdef DeviceBackgroundsPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        devices
    end
    
    methods
        
        function obj = DeviceBackgroundsPresenter(devices, app, view)
            if nargin < 3
                view = symphonyui.ui.views.DeviceBackgroundsView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.devices = devices;
        end
        
    end
    
    methods (Access = protected)

        function onGoing(obj, ~, ~)
            obj.populateBackgrounds();
            obj.view.pack();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Apply', @obj.onViewSelectedApply);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end
    
    methods (Access = private)
        
        function populateBackgrounds(obj)
            for i = 1:numel(obj.devices)
                d = obj.devices{i};
                [quantity, units] = d.getBackground();
                obj.view.addBackground(d.name, quantity, units);
            end
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.key
                case 'return'
                    obj.onViewSelectedApply();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedApply(obj, ~, ~)
            obj.view.update();
            
            try
                obj.applyBackgrounds();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.view.hide();
        end
        
        function applyBackgrounds(obj)
            for i = 1:numel(obj.devices)
                d = obj.devices{i};
                quantity = str2double(obj.view.getBackground(d.name));
                d.setBackground(quantity);
            end
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.view.hide();
        end
        
    end
    
end

