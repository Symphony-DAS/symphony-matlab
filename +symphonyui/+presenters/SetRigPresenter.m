classdef SetRigPresenter < symphonyui.Presenter
    
    properties (Access = private)
        controller
        rigMap
    end
    
    methods
        
        function obj = SetRigPresenter(controller, rigMap, view)
            if nargin < 2
                view = symphonyui.views.SetRigView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.controller = controller;
            obj.rigMap = rigMap;
            
            obj.addListener(controller, 'rig', 'PostSet', @obj.onSetRig);
            
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            view.setRigList(rigMap.keys);
            
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
        
        function onSetRig(obj, ~, ~)
            rig = obj.controller.rig;
            index = obj.rigMap.right_find(class(rig));
            key = obj.rigMap.right_at(index);
            obj.view.setRig(key);
        end
        
        function onSelectedOk(obj, ~, ~)
            drawnow();
            
            rig = obj.view.getRig();
            className = obj.rigMap(rig);
            constructor = str2func(className);
            
            obj.controller.setRig(constructor());
            
            obj.view.result = true;
        end
        
    end
    
end

