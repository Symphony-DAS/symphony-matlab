classdef SelectRigPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        acquisitionService
    end
    
    methods
        
        function obj = SelectRigPresenter(acquisitionService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.SelectRigView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.acquisitionService = acquisitionService;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            obj.populateRigList();
            obj.view.setSelectedRig(obj.acquisitionService.getCurrentRig().id);
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Ok', @obj.onViewSelectedOk);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
            
            s = obj.acquisitionService;
            obj.addListener(s, 'SelectedRig', @obj.onServiceSelectedRig);
        end
        
    end
    
    methods (Access = private)
        
        function onViewKeyPress(obj, ~, data)
            switch data.key
                case 'return'
                    obj.onViewSelectedOk();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function populateRigList(obj)
            obj.view.setRigList(obj.acquisitionService.getAvailableRigIds());
        end
        
        function onServiceSelectedRig(obj, ~, ~)
            obj.view.setSelectedRig(obj.acquisitionService.getCurrentRig().id);
        end
        
        function onViewSelectedOk(obj, ~, ~)
            obj.view.update();
            
            try
                obj.acquisitionService.getCurrentRig().close();
                obj.acquisitionService.selectRig(obj.view.getSelectedRig());
                obj.acquisitionService.getCurrentRig().initialize();
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

