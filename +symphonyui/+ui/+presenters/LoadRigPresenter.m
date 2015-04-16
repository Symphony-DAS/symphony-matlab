classdef LoadRigPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        acquisitionService
    end
    
    methods
        
        function obj = LoadRigPresenter(acquisitionService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.LoadRigView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.acquisitionService = acquisitionService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            
        end
        
        function onStopping(obj)
            
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'BrowseLocation', @obj.onViewSelectedBrowseLocation);
            obj.addListener(v, 'Load', @obj.onViewSelectedLoad);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
        
    end
    
    methods (Access = private)
        
        function onViewKeyPress(obj, ~, event)
            switch event.key
                case 'return'
                    obj.onViewSelectedLoad();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedBrowseLocation(obj, ~, ~)
            [filename, pathname] = uigetfile(pwd, 'Rig Location');
            if filename ~= 0
                location = fullfile(pathname, filename);
                obj.view.setLocation(location);
            end
        end
        
        function onViewSelectedLoad(obj, ~, ~)
            obj.view.update();
            
            location = obj.view.getLocation();
            
            try
                obj.acquisitionService.loadRig(location);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.view.hide();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.view.hide();
        end
        
    end
    
end

