classdef SelectRigPresenter < symphonyui.Presenter
    
    properties (Access = private)
        controller
        rigMap
    end
    
    methods
        
        function obj = SelectRigPresenter(controller, view)
            if nargin < 2
                view = symphonyui.views.SelectRigView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.controller = controller;
            
            obj.addListener(controller, 'SetRigList', @obj.onChangedRigList);
            obj.addListener(controller, 'SelectedRig', @obj.onControllerSelectedRig);
            
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
            obj.rigMap = symphonyui.util.displayNameMap(obj.controller.rigList);
            obj.view.setRigList(obj.rigMap.keys);
        end
        
        function onControllerSelectedRig(obj, ~, ~)
            rig = obj.controller.rig;
            index = obj.rigMap.right_find(class(rig));
            key = obj.rigMap.right_at(index);
            obj.view.setRig(key);
        end
        
        function onSelectedOk(obj, ~, ~)
            drawnow();
            
            key = obj.view.getRig();
            className = obj.rigMap(key);
            index = obj.controller.getRigIndex(className);
            
            try
                obj.controller.selectRig(index);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.view.result = true;
        end
        
    end
    
end

