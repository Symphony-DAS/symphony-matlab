classdef AddPropertyPresenter < symphonyui.ui.Presenter

    properties (Access = private)
        entity
    end

    methods

        function obj = AddPropertyPresenter(entity, app, view)
            if nargin < 3
                view = symphonyui.ui.views.AddPropertyView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.entity = entity;
        end

    end

    methods (Access = protected)

        function onGo(obj)
            obj.view.requestKeyFocus();
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Add', @obj.onViewSelectedAdd);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
    end

    methods (Access = private)

        function onViewKeyPress(obj, ~, event)
            switch event.key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();
            
            key = obj.view.getKey();
            value = obj.view.getValue();
            
            try
                obj.entity.addProperty(key, value);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            obj.view.hide();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.view.hide();
        end

    end

end
