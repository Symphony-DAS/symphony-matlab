classdef SetRigPresenter < symphonyui.Presenter
    
    properties (SetAccess = private)
        rig
    end
    
    methods
        
        function obj = SetRigPresenter(rigList, view)
            if nargin < 2
                view = symphonyui.views.SetRigView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
            
            view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            view.setRigList(rigList);
            view.enableOk(~isempty(rigList));
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
            obj.rig = obj.view.getRig();
            
            obj.view.result = true;
        end
        
    end
    
end

