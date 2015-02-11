classdef SelectRigPresenter < symphonyui.Presenter
    
    properties (Access = private)
        appController
        rigMap
    end
    
    methods
        
        function obj = SelectRigPresenter(appController, view)
            if nargin < 2
                view = symphonyui.views.SelectRigView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.appController = appController;
            
            obj.addListener(appController, 'ChangedRigList', @obj.onChangedRigList);
            obj.addListener(appController, 'SelectedRig', @obj.onControllerSelectedRig);
            
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.Presenter(obj);
            
            obj.view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            
            obj.onChangedRigList();
            obj.onControllerSelectedRig();
        end
        
    end
    
    methods (Access = private)
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedOK();
            elseif strcmp(data.Key, 'escape')
                obj.view.close();
            end
        end
        
        function onChangedRigList(obj, ~, ~)
            obj.rigMap = symphonyui.util.displayNameMap(obj.appController.rigList);
            obj.view.setRigList(obj.rigMap.keys);
        end
        
        function onControllerSelectedRig(obj, ~, ~)
            index = obj.appController.getRigIndex();
            key = obj.rigMap.right_at(index);
            obj.view.setRig(key);
        end
        
        function onSelectedOk(obj, ~, ~)
            drawnow();
            
            key = obj.view.getRig();
            className = obj.rigMap(key);
            index = obj.appController.getRigIndex(className);
            
            try
                obj.appController.selectRig(index);
                obj.appController.initializeRig();
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.view.result = true;
        end
        
    end
    
end

