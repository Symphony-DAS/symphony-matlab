classdef EntityPresetsPresenter < appbox.Presenter
    
    properties (Access = private)
        log
    end
    
    methods
        
        function obj = EntityPresetsPresenter(view)
            if nargin < 1
                view = symphonyui.ui.views.EntityPresetsView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.log = log4m.LogManager.getLogger(class(obj));
        end
        
    end
    
    methods (Access = protected)
        
        function willGo(obj)
            
        end
        
        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Ok', @obj.onViewSelectedOk);
        end
        
    end
    
    methods (Access = private)
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case {'return', 'escape'}
                    obj.onViewSelectedOk();
            end
        end

        function onViewSelectedOk(obj, ~, ~)
            obj.stop();
        end
        
    end
    
end

