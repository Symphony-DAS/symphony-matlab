classdef SetRigPresenter < SymphonyUI.Presenter
    
    properties (SetAccess = private)
        rig
    end
    
    properties (Access = private)
        rigMap
    end
    
    methods
        
        function obj = SetRigPresenter(rigMap, view)
            if nargin < 2
                view = SymphonyUI.Views.SetRigView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            
            obj.rigMap = rigMap;
            
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            view.setRigList(rigMap.keys);
            view.enableOk(~isempty(rigMap.keys));
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
        
        function onSelectedOk(obj, ~, ~)
            displayName = obj.view.getRig();            
            className = obj.rigMap(displayName);
            constructor = str2func(className);
            
            obj.rig = constructor();
            
            obj.view.result = true;
        end
        
    end
    
end

