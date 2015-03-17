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
            obj.addListener(view, 'Ok', @obj.onViewSelectedOk);
            obj.addListener(view, 'Cancel', @obj.onViewSelectedCancel);
            
            obj.acquisitionService = acquisitionService;
            obj.addListener(acquisitionService, 'ChangedAvailableRigs', @obj.onServiceChangedAvailableRigs);
            obj.addListener(acquisitionService, 'SelectedRig', @obj.onServiceSelectedRig);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.ui.Presenter(obj);
            
            obj.view.setWindowKeyPressFcn(@obj.onViewWindowKeyPress);
            obj.view.setRigList(obj.acquisitionService.getAvailableRigIds());
            obj.view.setSelectedRig(obj.acquisitionService.getCurrentRig().id);
        end
        
    end
    
    methods (Access = private)
        
        function onViewWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onViewSelectedOK();
            elseif strcmp(data.Key, 'escape')
                obj.onViewSelectedCancel();
            end
        end
        
        function onServiceChangedAvailableRigs(obj, ~, ~)
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
            
            obj.view.close();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.view.close();
        end
        
    end
    
end

