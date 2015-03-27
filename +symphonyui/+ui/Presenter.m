classdef Presenter < symphonyui.infra.mixin.Observer
    
    properties (Access = protected)
        log
        app
        view
    end
    
    methods
        
        function obj = Presenter(app, view)
            obj.log = org.apache.logging.log4j.LogManager.getLogger(class(obj));
            obj.app = app;
            obj.view = view;
        end
        
        function delete(obj)
            obj.stop();
        end
        
        function go(obj)
            obj.onGoing();
            obj.bind();
            obj.view.show();
            obj.onGo();
        end
        
        % A Presenter must be stopped or a memory leak will result.
        function stop(obj)
            obj.onStopping();
            obj.unbind();
            obj.view.close();
            obj.onStop();
        end
        
        function show(obj)
            obj.view.show();
        end
        
        function goWaitStop(obj)
            obj.go();
            obj.view.wait();
            obj.stop();
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj) %#ok<MANU>
            % Setup view before being shown for the first time.
        end
        
        function onGo(obj) %#ok<MANU>
            % Set focus on view component after being shown for the first time.       
        end
        
        function onStopping(obj) %#ok<MANU>
            % Teardown view before being closed forever.
        end
        
        function onStop(obj) %#ok<MANU>
            
        end
        
        function onBind(obj) %#ok<MANU>
            % Add view/model listeners.
        end
        
        function onUnbind(obj) %#ok<MANU>
            
        end
        
        function onViewSelectedClose(obj, ~, ~)
            obj.view.hide();
        end
        
    end
    
    methods (Access = private)
        
        function bind(obj)
            v = obj.view;
            obj.addListener(v, 'Close', @obj.onViewSelectedClose);
            obj.onBind();
        end
        
        function unbind(obj)
            obj.removeAllListeners();
            obj.onUnbind();
        end
        
    end
    
end

