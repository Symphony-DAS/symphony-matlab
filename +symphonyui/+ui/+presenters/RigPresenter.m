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
            
        end
        
    end
    
    methods (Access = private)
        
        function populateDeviceList(obj)
            devices = obj.rig.devices;
            for i = 1:numel(devices)
                obj.addDevice(devices{i});
            end
        end
        
        function addDevice(obj, device)
            d = device;
            obj.view.addDevice(d.name, 'IN', 'OUT', 'BACKGROUND');
        end
        
    end
    
end

