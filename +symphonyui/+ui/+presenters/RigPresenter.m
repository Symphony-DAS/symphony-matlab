classdef RigPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        rig
    end
    
    methods
        
        function obj = RigPresenter(rig, app, view)
            if nargin < 3
                view = symphonyui.ui.views.RigView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.rig = rig;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.view.setDaqController('PLACE_HOLDER');
            obj.populateDeviceList();
        end
        
        function onBind(obj)
            v = obj.view;
            
            r = obj.rig;
            for i = 1:numel(r.devices)
                obj.addListener(r.devices{i}, 'SetBackground', @obj.onDeviceSetBackground);
            end
        end
        
    end
    
    methods (Access = private)
        
        function populateDeviceList(obj)
            devices = obj.rig.devices;
            for i = 1:numel(devices)
                d = devices{i};
                [background, units] = d.getBackground();
                obj.view.addDevice(d.name, 'IN', 'OUT');
                obj.view.setDeviceBackground(d.name, background, units);
            end
        end
        
        function onDeviceSetBackground(obj, ~, event)
            d = event.Source;
            [background, units] = d.getBackground();
            obj.view.setDeviceBackground(d.name, background, units);
        end
        
    end
    
end

