classdef RigPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        rig
    end
    
    methods
        
        function obj = RigPresenter(rig, app, view)
            if nargin < 3
                view = symphonyui.ui.views.RigView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.rig = rig;
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj)
            
        end
        
        function onBind(obj)
            v = obj.view;
            
        end
        
    end
    
    methods (Access = private)
        
        function onViewKeyPress(obj, ~, event)
            switch event.key
%                 case 'return'
%                     obj.onViewSelectedLoad();
%                 case 'escape'
%                     obj.onViewSelectedCancel();
            end
        end
        
    end
    
end

