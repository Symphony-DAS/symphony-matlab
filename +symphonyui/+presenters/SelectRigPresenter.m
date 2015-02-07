classdef SelectRigPresenter < symphonyui.Presenter
    
    properties (Access = private)
        manager
        rigMap
    end
    
    methods
        
        function obj = SelectRigPresenter(manager, view)
            if nargin < 2
                view = symphonyui.views.SelectRigView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.manager = manager;
            
            obj.addListener(manager, 'SetRigList', @obj.onSetRigList);
            obj.addListener(manager, 'SelectedRig', @obj.onManagerSelectedRig);
            
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.Presenter(obj);
            
            obj.view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            
            obj.onSetRigList();
            obj.onManagerSelectedRig();
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
        
        function onSetRigList(obj, ~, ~)
            obj.rigMap = symphonyui.utilities.displayNameMap(obj.manager.rigList);
            obj.view.setRigList(obj.rigMap.keys);
        end
        
        function onManagerSelectedRig(obj, ~, ~)
            rig = obj.manager.rig;
            index = obj.rigMap.right_find(class(rig));
            key = obj.rigMap.right_at(index);
            obj.view.setRig(key);
        end
        
        function onSelectedOk(obj, ~, ~)
            drawnow();
            
            key = obj.view.getRig();
            className = obj.rigMap(key);
            index = obj.manager.getRigIndex(className);
            
            try
                obj.manager.selectRig(index);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.view.result = true;
        end
        
    end
    
end

