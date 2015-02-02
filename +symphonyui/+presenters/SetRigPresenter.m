classdef SetRigPresenter < symphonyui.Presenter
    
    properties (Access = private)
        appData
        rigMap
    end
    
    methods
        
        function obj = SetRigPresenter(appData, view)
            if nargin < 2
                view = symphonyui.views.SetRigView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.appData = appData;
            
            obj.addListener(appData, 'SetRigList', @obj.onSetRigList);
            obj.addListener(appData, 'SetRig', @obj.onSetRig);
            
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            
            obj.onSetRigList();
            obj.onSetRig();
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
            obj.rigMap = symphonyui.utilities.displayNameMap(obj.appData.rigList);
            obj.view.setRigList(obj.rigMap.keys);
        end
        
        function onSetRig(obj, ~, ~)
            rig = obj.appData.rig;
            index = obj.rigMap.right_find(class(rig));
            key = obj.rigMap.right_at(index);
            obj.view.setRig(key);
        end
        
        function onSelectedOk(obj, ~, ~)
            drawnow();
            
            obj.appData.rig.close();
            
            rig = obj.view.getRig();
            className = obj.rigMap(rig);
            index = obj.appData.getRigIndex(className);
            try
                obj.appData.setRig(index);
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                obj.onSetRig();
                return;
            end
            
            try
                obj.appData.rig.initialize();
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                return;
            end
            
            obj.view.result = true;
        end
        
    end
    
end

