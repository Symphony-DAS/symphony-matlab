classdef SelectRigPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        mainService
    end
    
    methods
        
        function obj = SelectRigPresenter(mainService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.SelectRigView([]);
            end
            
            obj = obj@symphonyui.ui.Presenter(app, view);            
            obj.addListener(view, 'Ok', @obj.onViewSelectedOk);
            obj.addListener(view, 'Cancel', @obj.onViewSelectedCancel);
            
            obj.mainService = mainService;
            obj.addListener(mainService, 'ChangedAvailableRigs', @obj.onServiceChangedAvailableRigs);
            obj.addListener(mainService, 'SelectedRig', @obj.onServiceSelectedRig);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.ui.Presenter(obj);
            
            obj.view.setWindowKeyPressFcn(@obj.onViewWindowKeyPress);
            obj.view.setRigList(obj.mainService.getAvailableRigIds());
            obj.view.setSelectedRig(obj.mainService.getCurrentRig().id);
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
            obj.view.setRigList(obj.mainService.getAvailableRigIds());
        end
        
        function onServiceSelectedRig(obj, ~, ~)
            obj.view.setSelectedRig(obj.mainService.getCurrentRig().id);
        end
        
        function onViewSelectedOk(obj, ~, ~)
            obj.view.update();
            
            try
                obj.mainService.getCurrentRig().close();
                obj.mainService.selectRig(obj.view.getSelectedRig());
                obj.mainService.getCurrentRig().initialize();
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

