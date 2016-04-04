classdef AddEntityPresetPresenter < appbox.Presenter

    properties (Access = private)
        log
    end

    methods

        function obj = AddEntityPresetPresenter(view)
            if nargin < 1
                view = symphonyui.ui.views.AddEntityPresetView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
        end

    end

    methods (Access = protected)
        
        function willGo(obj)
            
        end

        function didGo(obj)
            obj.view.requestNameFocus();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Add', @obj.onViewSelectedAdd);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
    end

    methods (Access = private)

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();
            
            
            
            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

    end

end
